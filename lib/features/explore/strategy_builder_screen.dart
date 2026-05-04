import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/models/bet.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/bet_service.dart';

// ── Enums / constants ─────────────────────────────────────────────────────────

enum _PreferredSelection { home, draw, away, mixed }

enum _OddsFilter { low, medium, high }

extension _PreferredSelectionLabel on _PreferredSelection {
  String get label {
    switch (this) {
      case _PreferredSelection.home:
        return 'Home Win';
      case _PreferredSelection.draw:
        return 'Draw';
      case _PreferredSelection.away:
        return 'Away Win';
      case _PreferredSelection.mixed:
        return 'Mixed (All)';
    }
  }
}

extension _OddsFilterLabel on _OddsFilter {
  String get label {
    switch (this) {
      case _OddsFilter.low:
        return '1.5 – 2.0';
      case _OddsFilter.medium:
        return '2.0 – 3.0';
      case _OddsFilter.high:
        return '3.0+';
    }
  }

  bool matches(double odds) {
    switch (this) {
      case _OddsFilter.low:
        return odds >= 1.5 && odds < 2.0;
      case _OddsFilter.medium:
        return odds >= 2.0 && odds < 3.0;
      case _OddsFilter.high:
        return odds >= 3.0;
    }
  }
}

// ── Result data class ─────────────────────────────────────────────────────────

class _SimResult {
  final int betsPlayed;
  final int wins;
  final int losses;
  final double totalStaked;
  final double totalReturned;
  final double pnl;
  final double winRate;
  final double roi;
  final String stopReason; // '', 'stop_loss', 'take_profit'

  const _SimResult({
    required this.betsPlayed,
    required this.wins,
    required this.losses,
    required this.totalStaked,
    required this.totalReturned,
    required this.pnl,
    required this.winRate,
    required this.roi,
    required this.stopReason,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StrategyBuilderScreen extends StatefulWidget {
  const StrategyBuilderScreen({super.key});

  @override
  State<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends State<StrategyBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final BetService _betService;
  late final AuthService _authService;
  final _currencyFmt =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  // ── Form state ──────────────────────────────────────────────────────────
  double _fixedStake = 10.0;
  _PreferredSelection _preferredSelection = _PreferredSelection.mixed;
  _OddsFilter _oddsFilter = _OddsFilter.medium;
  double _stopLoss = 100.0;
  double _takeProfit = 200.0;

  // ── Data / simulation state ─────────────────────────────────────────────
  List<PlacedBet> _allBets = [];
  bool _loadingBets = false;
  bool _simulating = false;
  String? _loadError;
  _SimResult? _result;

  // Animation controller for result reveal
  late final AnimationController _revealCtrl;
  late final Animation<double> _revealAnim;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _betService = BetService(api);
    _authService = AuthService(api);

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealCtrl,
      curve: Curves.easeOutCubic,
    );

    _fetchBets();
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  // ── Data fetching ───────────────────────────────────────────────────────

  Future<void> _fetchBets() async {
    setState(() {
      _loadingBets = true;
      _loadError = null;
    });
    try {
      await _authService.syncTokenToApi();
      final resp = await _betService.getMyBets(limit: 200, offset: 0);
      if (mounted) {
        setState(() {
          _allBets = resp.bets;
          _loadingBets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loadingBets = false;
        });
      }
    }
  }

  // ── Simulation logic ────────────────────────────────────────────────────

  Future<void> _runSimulation() async {
    if (_allBets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No bet history available to simulate.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: context.cardBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _simulating = true;
      _result = null;
    });
    _revealCtrl.reset();

    // Small artificial delay for perceived "computing" feel
    await Future.delayed(const Duration(milliseconds: 400));

    // ── Filter bets by selection preference ──
    List<PlacedBet> filtered = _allBets.where((b) {
      // Selection filter
      if (_preferredSelection != _PreferredSelection.mixed) {
        final selName = b.selection.name.toLowerCase();
        final wanted = _preferredSelection.name.toLowerCase();
        if (selName != wanted) return false;
      }
      // Odds filter
      if (!_oddsFilter.matches(b.odds)) return false;
      // Only use resolved bets for realistic simulation
      final status = b.status.toLowerCase();
      if (status == 'cancelled') return false;
      return true;
    }).toList();

    // Sort chronologically
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // ── Replay with fixed stake ──
    int betsPlayed = 0;
    int wins = 0;
    int losses = 0;
    double totalStaked = 0;
    double totalReturned = 0;
    double runningPnl = 0;
    String stopReason = '';

    for (final bet in filtered) {
      final stakeThisBet = _fixedStake;
      totalStaked += stakeThisBet;
      betsPlayed++;

      final status = bet.status.toLowerCase();
      if (status == 'won') {
        // Re-compute payout using the actual odds but our fixed stake
        final payout = stakeThisBet * bet.odds;
        totalReturned += payout;
        runningPnl += (payout - stakeThisBet);
        wins++;
      } else if (status == 'lost' || status == 'pending') {
        runningPnl -= stakeThisBet;
        if (status == 'lost') losses++;
      }

      // Stop-loss / take-profit checks
      if (runningPnl <= -_stopLoss) {
        stopReason = 'stop_loss';
        break;
      }
      if (runningPnl >= _takeProfit) {
        stopReason = 'take_profit';
        break;
      }
    }

    final pnl = totalReturned - totalStaked;
    final winRate = betsPlayed > 0 ? (wins / betsPlayed * 100) : 0.0;
    final roi = totalStaked > 0 ? (pnl / totalStaked * 100) : 0.0;

    if (mounted) {
      setState(() {
        _result = _SimResult(
          betsPlayed: betsPlayed,
          wins: wins,
          losses: losses,
          totalStaked: totalStaked,
          totalReturned: totalReturned,
          pnl: pnl,
          winRate: winRate,
          roi: roi,
          stopReason: stopReason,
        );
        _simulating = false;
      });
      _revealCtrl.forward();
    }
  }

  // ── UI helpers ──────────────────────────────────────────────────────────

  String _fmt(double v) => _currencyFmt.format(v);

  Color _pnlColor(double v) =>
      v >= 0 ? AppColors.accentGreen : AppColors.betLoss;

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: AppTextStyles.overline
              .copyWith(color: context.textSecondary, letterSpacing: 2),
        ),
      );

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Strategy Builder',
          style: AppTextStyles.h3.copyWith(color: context.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (_loadingBets)
            const Padding(
              padding: EdgeInsets.only(right: 18),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.accentGreen,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (_loadError != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.accentGreen),
              onPressed: _fetchBets,
              tooltip: 'Reload history',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ───────────────────────────────────────────────────
            _buildBanner(),
            const SizedBox(height: 28),

            // ── Parameters form ──────────────────────────────────────────
            _sectionLabel('STRATEGY PARAMETERS'),
            _buildFormCard(),
            const SizedBox(height: 24),

            // ── Simulate button ──────────────────────────────────────────
            _buildSimulateButton(),
            const SizedBox(height: 28),

            // ── Result ───────────────────────────────────────────────────
            if (_result != null) ...[
              _sectionLabel('SIMULATION RESULTS'),
              FadeTransition(
                opacity: _revealAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(_revealAnim),
                  child: _buildResultCard(_result!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB74D).withValues(alpha: 0.18),
            AppColors.accentGreen.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: Color(0xFFFFB74D), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strategy Simulator',
                  style:
                      AppTextStyles.h4.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Test a fixed-stake strategy against your real bet history.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Form card ─────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fixed stake slider ─────────────────────────────────────────
          _buildSliderSection(
            icon: Icons.payments_rounded,
            iconColor: AppColors.accentGreen,
            title: 'Fixed Stake',
            subtitle: 'Amount to wager on each bet',
            valueLabel: _fmt(_fixedStake),
            valueLabelColor: AppColors.accentGreen,
            child: SliderTheme(
              data: _sliderTheme(AppColors.accentGreen),
              child: Slider(
                value: _fixedStake,
                min: 1,
                max: 500,
                divisions: 99,
                onChanged: (v) => setState(() => _fixedStake = v),
              ),
            ),
            minLabel: '\$1',
            maxLabel: '\$500',
          ),
          _divider(),

          // ── Preferred selection ────────────────────────────────────────
          _buildDropdownSection<_PreferredSelection>(
            icon: Icons.sports_soccer_rounded,
            iconColor: const Color(0xFF4A90E2),
            title: 'Preferred Selection',
            subtitle: 'Which outcome to bet on',
            value: _preferredSelection,
            items: _PreferredSelection.values,
            labelBuilder: (v) => v.label,
            onChanged: (v) {
              if (v != null) setState(() => _preferredSelection = v);
            },
          ),
          _divider(),

          // ── Odds filter ────────────────────────────────────────────────
          _buildDropdownSection<_OddsFilter>(
            icon: Icons.calculate_rounded,
            iconColor: AppColors.accentOrange,
            title: 'Odds Range',
            subtitle: 'Filter bets by odds bracket',
            value: _oddsFilter,
            items: _OddsFilter.values,
            labelBuilder: (v) => v.label,
            onChanged: (v) {
              if (v != null) setState(() => _oddsFilter = v);
            },
          ),
          _divider(),

          // ── Stop loss slider ───────────────────────────────────────────
          _buildSliderSection(
            icon: Icons.trending_down_rounded,
            iconColor: AppColors.betLoss,
            title: 'Stop Loss',
            subtitle: 'Stop if cumulative loss exceeds',
            valueLabel: _fmt(_stopLoss),
            valueLabelColor: AppColors.betLoss,
            child: SliderTheme(
              data: _sliderTheme(AppColors.betLoss),
              child: Slider(
                value: _stopLoss,
                min: 10,
                max: 1000,
                divisions: 99,
                onChanged: (v) => setState(() => _stopLoss = v),
              ),
            ),
            minLabel: '\$10',
            maxLabel: '\$1 000',
          ),
          _divider(),

          // ── Take profit slider ─────────────────────────────────────────
          _buildSliderSection(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.betDraw,
            title: 'Take Profit',
            subtitle: 'Stop if cumulative gain reaches',
            valueLabel: _fmt(_takeProfit),
            valueLabelColor: AppColors.betDraw,
            child: SliderTheme(
              data: _sliderTheme(AppColors.betDraw),
              child: Slider(
                value: _takeProfit,
                min: 10,
                max: 5000,
                divisions: 499,
                onChanged: (v) => setState(() => _takeProfit = v),
              ),
            ),
            minLabel: '\$10',
            maxLabel: '\$5 000',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, color: context.borderSubtle),
      );

  SliderThemeData _sliderTheme(Color color) {
    return SliderThemeData(
      activeTrackColor: color,
      inactiveTrackColor: color.withValues(alpha: 0.15),
      thumbColor: color,
      overlayColor: color.withValues(alpha: 0.15),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      trackHeight: 4,
    );
  }

  Widget _buildSliderSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String valueLabel,
    required Color valueLabelColor,
    required Widget child,
    required String minLabel,
    required String maxLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        AppTextStyles.label.copyWith(color: context.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: context.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: valueLabelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: valueLabelColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Text(
                valueLabel,
                style: AppTextStyles.label.copyWith(
                  color: valueLabelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary, fontSize: 10),
              ),
              Text(
                maxLabel,
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSection<T>({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.label.copyWith(color: context.textPrimary),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.surfaceBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              dropdownColor: context.cardBg,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: context.textSecondary, size: 18),
              style: AppTextStyles.label.copyWith(color: context.textPrimary),
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        labelBuilder(item),
                        style: AppTextStyles.label
                            .copyWith(color: context.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Simulate button ───────────────────────────────────────────────────────

  Widget _buildSimulateButton() {
    final canSim = !_loadingBets && !_simulating && _loadError == null;
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: canSim
              ? const LinearGradient(
                  colors: [AppColors.accentGreen, Color(0xFF00CC70)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: canSim ? null : context.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSim
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canSim ? _runSimulation : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: _simulating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            color: canSim ? Colors.black : context.iconInactive,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Run Simulation',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: canSim
                                  ? Colors.black
                                  : context.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Result card ───────────────────────────────────────────────────────────

  Widget _buildResultCard(_SimResult r) {
    final isProfit = r.pnl >= 0;
    final pnlColor = _pnlColor(r.pnl);

    return Column(
      children: [
        // ── Main P&L hero card ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                pnlColor.withValues(alpha: 0.18),
                pnlColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pnlColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Simulated P&L',
                style: AppTextStyles.label
                    .copyWith(color: context.textSecondary),
              ),
              const SizedBox(height: 10),
              Text(
                '${isProfit ? '+' : ''}${_fmt(r.pnl)}',
                style: AppTextStyles.h1.copyWith(
                  color: pnlColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: pnlColor.withValues(alpha: 0.35), width: 1),
                ),
                child: Text(
                  'ROI: ${r.roi >= 0 ? '+' : ''}${r.roi.toStringAsFixed(2)}%',
                  style: AppTextStyles.label.copyWith(
                    color: pnlColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (r.stopReason.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildStopBanner(r.stopReason),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── KPI grid ───────────────────────────────────────────────────
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.65,
          children: [
            _buildResultKpi(
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFF4A90E2),
              label: 'Bets Played',
              value: r.betsPlayed.toString(),
              valueColor: const Color(0xFF4A90E2),
            ),
            _buildResultKpi(
              icon: Icons.percent_rounded,
              iconColor: AppColors.accentGreen,
              label: 'Win Rate',
              value: '${r.winRate.toStringAsFixed(1)}%',
              valueColor: AppColors.accentGreen,
            ),
            _buildResultKpi(
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.betWin,
              label: 'Wins',
              value: r.wins.toString(),
              valueColor: AppColors.betWin,
            ),
            _buildResultKpi(
              icon: Icons.cancel_outlined,
              iconColor: AppColors.betLoss,
              label: 'Losses',
              value: r.losses.toString(),
              valueColor: AppColors.betLoss,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Staked vs Returned ─────────────────────────────────────────
        _buildStakedReturnedRow(r),
        const SizedBox(height: 14),

        // ── Strategy summary ────────────────────────────────────────────
        _buildStrategySummary(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStopBanner(String reason) {
    final isStopLoss = reason == 'stop_loss';
    final color =
        isStopLoss ? AppColors.betLoss : AppColors.accentGreen;
    final icon = isStopLoss
        ? Icons.stop_circle_rounded
        : Icons.celebration_rounded;
    final text = isStopLoss
        ? 'Stop-loss triggered at ${_fmt(_stopLoss)} loss'
        : 'Take-profit reached at ${_fmt(_takeProfit)} gain';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultKpi({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.h3.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStakedReturnedRow(_SimResult r) {
    final maxVal = r.totalStaked > r.totalReturned
        ? r.totalStaked
        : r.totalReturned;
    final safeDivide = maxVal > 0 ? maxVal : 1.0;
    final stakedFrac = (r.totalStaked / safeDivide).clamp(0.0, 1.0);
    final retFrac = (r.totalReturned / safeDivide).clamp(0.0, 1.0);
    final isProfit = r.pnl >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capital Flow',
            style: AppTextStyles.label.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 16),
          _barRow(
            label: 'Staked',
            fraction: stakedFrac,
            amount: _fmt(r.totalStaked),
            color: context.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          _barRow(
            label: 'Returned',
            fraction: retFrac,
            amount: _fmt(r.totalReturned),
            color: isProfit ? AppColors.accentGreen : AppColors.betLoss,
          ),
        ],
      ),
    );
  }

  Widget _barRow({
    required String label,
    required double fraction,
    required String amount,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style:
                AppTextStyles.caption.copyWith(color: context.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final barW =
                  constraints.maxWidth * fraction.clamp(0.0, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    height: 10,
                    width: barW,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          amount,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStrategySummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Strategy Summary',
            style: AppTextStyles.label.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            icon: Icons.payments_rounded,
            iconColor: AppColors.accentGreen,
            label: 'Fixed Stake',
            value: _fmt(_fixedStake),
          ),
          _summaryRow(
            icon: Icons.sports_soccer_rounded,
            iconColor: const Color(0xFF4A90E2),
            label: 'Selection',
            value: _preferredSelection.label,
          ),
          _summaryRow(
            icon: Icons.calculate_rounded,
            iconColor: AppColors.accentOrange,
            label: 'Odds Range',
            value: _oddsFilter.label,
          ),
          _summaryRow(
            icon: Icons.trending_down_rounded,
            iconColor: AppColors.betLoss,
            label: 'Stop Loss',
            value: _fmt(_stopLoss),
          ),
          _summaryRow(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.betDraw,
            label: 'Take Profit',
            value: _fmt(_takeProfit),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label
                      .copyWith(color: context.textSecondary),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.label.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: context.borderSubtle),
      ],
    );
  }
}
