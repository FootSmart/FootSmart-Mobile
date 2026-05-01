import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/models/bet.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/bet_service.dart';

class BetHistoryAnalyticsScreen extends StatefulWidget {
  const BetHistoryAnalyticsScreen({super.key});

  @override
  State<BetHistoryAnalyticsScreen> createState() =>
      _BetHistoryAnalyticsScreenState();
}

class _BetHistoryAnalyticsScreenState
    extends State<BetHistoryAnalyticsScreen> {
  late final BetService _betService;
  late final AuthService _authService;

  final _currencyFmt =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<PlacedBet> _bets = [];
  bool _isLoading = true;
  String? _error;

  // ── Computed analytics (populated in _computeAnalytics) ─────────────────
  double _totalStaked = 0;
  double _totalReturned = 0;
  int _wonCount = 0;
  int _lostCount = 0;
  int _pendingCount = 0;
  int _cancelledCount = 0;

  // Selection breakdown
  final Map<String, _SelectionStats> _selectionStats = {
    'home': _SelectionStats(),
    'draw': _SelectionStats(),
    'away': _SelectionStats(),
  };

  List<PlacedBet> _top5Bets = [];
  int _currentStreak = 0;
  bool _streakIsWin = true;

  // Monthly – last 3 months
  final List<_MonthData> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _betService = BetService(api);
    _authService = AuthService(api);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.syncTokenToApi();
      final response = await _betService.getMyBets(limit: 200, offset: 0);
      if (mounted) {
        _bets = response.bets;
        _computeAnalytics();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── Analytics computation ────────────────────────────────────────────────

  void _computeAnalytics() {
    _totalStaked = 0;
    _totalReturned = 0;
    _wonCount = 0;
    _lostCount = 0;
    _pendingCount = 0;
    _cancelledCount = 0;
    _selectionStats
      ..['home'] = _SelectionStats()
      ..['draw'] = _SelectionStats()
      ..['away'] = _SelectionStats();
    _monthlyData.clear();

    for (final bet in _bets) {
      _totalStaked += bet.stake;
      final status = bet.status.toLowerCase();

      if (status == 'won') {
        _wonCount++;
        _totalReturned += bet.potentialPayout;
      } else if (status == 'lost') {
        _lostCount++;
      } else if (status == 'pending') {
        _pendingCount++;
      } else if (status == 'cancelled') {
        _cancelledCount++;
      }

      // Selection stats
      final sel = bet.selection.name.toLowerCase();
      final stats = _selectionStats[sel];
      if (stats != null) {
        stats.total++;
        if (status == 'won') stats.won++;
      }
    }

    // Top 5 by potential payout (won only first, fallback all)
    final resolved =
        _bets.where((b) => b.status.toLowerCase() == 'won').toList();
    resolved.sort((a, b) => b.potentialPayout.compareTo(a.potentialPayout));
    _top5Bets = resolved.take(5).toList();
    if (_top5Bets.isEmpty) {
      final allSorted = List<PlacedBet>.from(_bets)
        ..sort((a, b) => b.potentialPayout.compareTo(a.potentialPayout));
      _top5Bets = allSorted.take(5).toList();
    }

    // Streak – iterate from most recent resolved bet
    final resolved2 = _bets
        .where((b) =>
            b.status.toLowerCase() == 'won' ||
            b.status.toLowerCase() == 'lost')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _currentStreak = 0;
    if (resolved2.isNotEmpty) {
      _streakIsWin = resolved2.first.status.toLowerCase() == 'won';
      for (final bet in resolved2) {
        final isWin = bet.status.toLowerCase() == 'won';
        if (isWin == _streakIsWin) {
          _currentStreak++;
        } else {
          break;
        }
      }
    }

    // Monthly – last 3 months
    final now = DateTime.now();
    for (int i = 2; i >= 0; i--) {
      final targetDate =
          DateTime(now.year, now.month - i, 1);
      final month =
          DateTime(targetDate.year, targetDate.month, 1);
      final nextMonth =
          DateTime(targetDate.year, targetDate.month + 1, 1);

      double staked = 0;
      double returned = 0;
      for (final bet in _bets) {
        if (bet.createdAt.isAfter(month) &&
            bet.createdAt.isBefore(nextMonth)) {
          staked += bet.stake;
          if (bet.status.toLowerCase() == 'won') {
            returned += bet.potentialPayout;
          }
        }
      }
      _monthlyData.add(_MonthData(
        label: DateFormat('MMM').format(month),
        staked: staked,
        returned: returned,
      ));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

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
          'Bet History Analytics',
          style: AppTextStyles.h3.copyWith(color: context.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && _bets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${_bets.length} bets',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        backgroundColor: context.cardBg,
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_bets.isEmpty) return _buildEmpty();
    return _buildContent();
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.accentGreen,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.betLoss.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppColors.betLoss, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load bet history',
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderSubtle),
                ),
                child: Icon(Icons.history_rounded,
                    color: context.iconInactive, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'No Bets Yet',
                style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Place your first bet to unlock analytics here.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // ── 1. Staked vs Returned ─────────────────────────────────────────
        _buildSectionLabel('TOTAL STAKED VS RETURNED'),
        const SizedBox(height: 12),
        _buildStakedVsReturned(),
        const SizedBox(height: 24),

        // ── 2. Status breakdown ───────────────────────────────────────────
        _buildSectionLabel('STATUS BREAKDOWN'),
        const SizedBox(height: 12),
        _buildStatusBreakdown(),
        const SizedBox(height: 24),

        // ── 3. Current streak ─────────────────────────────────────────────
        _buildSectionLabel('CURRENT STREAK'),
        const SizedBox(height: 12),
        _buildStreakCard(),
        const SizedBox(height: 24),

        // ── 4. Selection breakdown ────────────────────────────────────────
        _buildSectionLabel('SELECTION BREAKDOWN'),
        const SizedBox(height: 12),
        _buildSelectionBreakdown(),
        const SizedBox(height: 24),

        // ── 5. Monthly trend (last 3 months) ─────────────────────────────
        _buildSectionLabel('3-MONTH TREND'),
        const SizedBox(height: 12),
        _buildMonthlyTrend(),
        const SizedBox(height: 24),

        // ── 6. Top 5 best bets ────────────────────────────────────────────
        if (_top5Bets.isNotEmpty) ...[
          _buildSectionLabel('TOP 5 BEST BETS'),
          const SizedBox(height: 12),
          ..._top5Bets.asMap().entries.map(
                (e) => _buildTopBetRow(rank: e.key + 1, bet: e.value),
              ),
        ],
      ],
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.overline
          .copyWith(color: context.textSecondary, letterSpacing: 2),
    );
  }

  // ── 1. Staked vs Returned ─────────────────────────────────────────────────

  Widget _buildStakedVsReturned() {
    final pnl = _totalReturned - _totalStaked;
    final isPositive = pnl >= 0;
    final maxVal = _totalStaked > _totalReturned
        ? _totalStaked
        : _totalReturned;
    final safeDivide = maxVal > 0 ? maxVal : 1.0;
    final stakedFrac = (_totalStaked / safeDivide).clamp(0.0, 1.0);
    final retFrac = (_totalReturned / safeDivide).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          // Summary row
          Row(
            children: [
              Expanded(
                child: _buildAmountTile(
                  label: 'Total Staked',
                  amount: _currencyFmt.format(_totalStaked),
                  color: context.textSecondary,
                ),
              ),
              Container(width: 1, height: 40, color: context.borderSubtle),
              Expanded(
                child: _buildAmountTile(
                  label: 'Total Returned',
                  amount: _currencyFmt.format(_totalReturned),
                  color: isPositive ? AppColors.accentGreen : AppColors.betLoss,
                  center: true,
                ),
              ),
              Container(width: 1, height: 40, color: context.borderSubtle),
              Expanded(
                child: _buildAmountTile(
                  label: 'Net P&L',
                  amount:
                      '${isPositive ? '+' : ''}${_currencyFmt.format(pnl)}',
                  color: isPositive ? AppColors.accentGreen : AppColors.betLoss,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Staked bar
          _buildComparisonBar(
            label: 'Staked',
            fraction: stakedFrac,
            amount: _currencyFmt.format(_totalStaked),
            color: context.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          // Returned bar
          _buildComparisonBar(
            label: 'Returned',
            fraction: retFrac,
            amount: _currencyFmt.format(_totalReturned),
            color:
                isPositive ? AppColors.accentGreen : AppColors.betLoss,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountTile({
    required String label,
    required String amount,
    required Color color,
    bool center = false,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : align,
      children: [
        Text(
          label,
          style:
              AppTextStyles.caption.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.label.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildComparisonBar({
    required String label,
    required double fraction,
    required String amount,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
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
                    height: 12,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    height: 12,
                    width: barW,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
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

  // ── 2. Status breakdown (stacked bar) ─────────────────────────────────────

  Widget _buildStatusBreakdown() {
    final total = _bets.length;
    final safeDivide = total > 0 ? total.toDouble() : 1.0;

    final wonFrac = _wonCount / safeDivide;
    final lostFrac = _lostCount / safeDivide;
    final pendFrac = _pendingCount / safeDivide;
    final cancelFrac = _cancelledCount / safeDivide;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          // Stacked horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 18,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final w = constraints.maxWidth;
                  return Row(
                    children: [
                      if (wonFrac > 0)
                        _stackedSegment(
                            w * wonFrac, AppColors.betWin),
                      if (lostFrac > 0)
                        _stackedSegment(
                            w * lostFrac, AppColors.betLoss),
                      if (pendFrac > 0)
                        _stackedSegment(
                            w * pendFrac, AppColors.betDraw),
                      if (cancelFrac > 0)
                        _stackedSegment(
                            w * cancelFrac, context.iconInactive),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Legend grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.2,
            children: [
              _buildStatusLegendItem(
                  color: AppColors.betWin,
                  label: 'Won',
                  count: _wonCount,
                  total: total),
              _buildStatusLegendItem(
                  color: AppColors.betLoss,
                  label: 'Lost',
                  count: _lostCount,
                  total: total),
              _buildStatusLegendItem(
                  color: AppColors.betDraw,
                  label: 'Pending',
                  count: _pendingCount,
                  total: total),
              _buildStatusLegendItem(
                  color: context.iconInactive,
                  label: 'Cancelled',
                  count: _cancelledCount,
                  total: total),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stackedSegment(double width, Color color) {
    return Container(
      width: width,
      height: 18,
      color: color,
    );
  }

  Widget _buildStatusLegendItem({
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final pct = total > 0 ? (count / total * 100) : 0.0;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary, fontSize: 11),
              ),
              Text(
                '$count (${pct.toStringAsFixed(0)}%)',
                style: AppTextStyles.label.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3. Streak ─────────────────────────────────────────────────────────────

  Widget _buildStreakCard() {
    final color = _streakIsWin ? AppColors.accentGreen : AppColors.betLoss;
    final icon =
        _streakIsWin ? Icons.local_fire_department_rounded : Icons.trending_down_rounded;
    final label = _streakIsWin ? 'WIN STREAK' : 'LOSS STREAK';
    final message = _streakIsWin
        ? 'Keep it up! You\'re on fire 🔥'
        : 'Don\'t worry, the next win is coming 💪';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.overline.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentStreak.toString(),
                      style: AppTextStyles.h1.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _currentStreak == 1 ? 'bet' : 'bets',
                        style: AppTextStyles.label
                            .copyWith(color: context.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
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

  // ── 4. Selection breakdown ────────────────────────────────────────────────

  Widget _buildSelectionBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Selection',
                    style: AppTextStyles.caption
                        .copyWith(color: context.textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bets',
                    style: AppTextStyles.caption
                        .copyWith(color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Win Rate',
                    style: AppTextStyles.caption
                        .copyWith(color: context.textSecondary),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.borderSubtle),
          _buildSelRow(
            label: 'HOME',
            icon: Icons.home_rounded,
            color: const Color(0xFF4A90E2),
            stats: _selectionStats['home']!,
          ),
          Divider(height: 1, color: context.borderSubtle, indent: 16),
          _buildSelRow(
            label: 'DRAW',
            icon: Icons.horizontal_rule_rounded,
            color: AppColors.betDraw,
            stats: _selectionStats['draw']!,
          ),
          Divider(height: 1, color: context.borderSubtle, indent: 16),
          _buildSelRow(
            label: 'AWAY',
            icon: Icons.flight_land_rounded,
            color: const Color(0xFF9D4EDD),
            stats: _selectionStats['away']!,
          ),
        ],
      ),
    );
  }

  Widget _buildSelRow({
    required String label,
    required IconData icon,
    required Color color,
    required _SelectionStats stats,
  }) {
    final rate =
        stats.total > 0 ? (stats.won / stats.total * 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Bet count
          Expanded(
            flex: 2,
            child: Text(
              stats.total.toString(),
              style: AppTextStyles.label
                  .copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          // Win rate bar + pct
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${rate.toStringAsFixed(1)}%',
                  style: AppTextStyles.label.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final barW = constraints.maxWidth *
                        (rate.clamp(0, 100) / 100);
                    return Stack(
                      children: [
                        Container(
                          height: 5,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 5,
                          width: barW,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Monthly trend ──────────────────────────────────────────────────────

  Widget _buildMonthlyTrend() {
    double maxVal = 1;
    for (final m in _monthlyData) {
      if (m.staked > maxVal) maxVal = m.staked;
      if (m.returned > maxVal) maxVal = m.returned;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            children: [
              _buildLegendDot(AppColors.accentGreen, 'Returned'),
              const SizedBox(width: 16),
              _buildLegendDot(
                  context.textSecondary.withValues(alpha: 0.45), 'Staked'),
            ],
          ),
          const SizedBox(height: 20),
          // Bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _monthlyData.map((m) {
              return Expanded(
                child: _buildMonthColumn(
                  label: m.label,
                  staked: m.staked,
                  returned: m.returned,
                  maxVal: maxVal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Monthly summary rows
          ..._monthlyData.map((m) => _buildMonthlySummaryRow(m)),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMonthColumn({
    required String label,
    required double staked,
    required double returned,
    required double maxVal,
  }) {
    const maxHeight = 90.0;
    final stakedH =
        maxVal > 0 ? (staked / maxVal) * maxHeight : 0.0;
    final retH =
        maxVal > 0 ? (returned / maxVal) * maxHeight : 0.0;
    final isProfit = returned >= staked;
    final retColor =
        isProfit ? AppColors.accentGreen : AppColors.betLoss;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Staked bar
              Container(
                width: 14,
                height: stakedH.clamp(2.0, maxHeight),
                decoration: BoxDecoration(
                  color: context.textSecondary.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 3),
              // Returned bar
              Container(
                width: 14,
                height: retH.clamp(2.0, maxHeight),
                decoration: BoxDecoration(
                  color: retColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                  boxShadow: isProfit
                      ? [
                          BoxShadow(
                            color: AppColors.accentGreen.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, -1),
                          )
                        ]
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryRow(_MonthData m) {
    final pnl = m.returned - m.staked;
    final isProfit = pnl >= 0;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              m.label,
              style: AppTextStyles.label.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Staked ${_currencyFmt.format(m.staked)}',
              style: AppTextStyles.caption
                  .copyWith(color: context.textSecondary),
            ),
          ),
          Text(
            '${isProfit ? '+' : ''}${_currencyFmt.format(pnl)}',
            style: AppTextStyles.label.copyWith(
              color: isProfit ? AppColors.accentGreen : AppColors.betLoss,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Top 5 bets ─────────────────────────────────────────────────────────

  Widget _buildTopBetRow({required int rank, required PlacedBet bet}) {
    final isWon = bet.status.toLowerCase() == 'won';
    final statusColor =
        isWon ? AppColors.betWin : AppColors.betDraw;
    final dateStr =
        DateFormat('dd MMM yy').format(bet.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : context.surfaceBg,
              shape: BoxShape.circle,
              border: rank == 1
                  ? Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.4),
                      width: 1.5)
                  : null,
            ),
            child: Text(
              '#$rank',
              style: AppTextStyles.overline.copyWith(
                color: rank == 1
                    ? AppColors.accentGreen
                    : context.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Teams + selection
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bet.homeTeam} vs ${bet.awayTeam}',
                  style: AppTextStyles.label
                      .copyWith(color: context.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        bet.selectionLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: AppTextStyles.caption
                          .copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Payout + odds
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFmt.format(bet.potentialPayout),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '@${bet.odds.toStringAsFixed(2)}',
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _SelectionStats {
  int total = 0;
  int won = 0;
}

class _MonthData {
  final String label;
  final double staked;
  final double returned;

  _MonthData({
    required this.label,
    required this.staked,
    required this.returned,
  });
}
