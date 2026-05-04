import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/services/analytics_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';

class MarketMovementsScreen extends StatefulWidget {
  const MarketMovementsScreen({super.key});

  @override
  State<MarketMovementsScreen> createState() => _MarketMovementsScreenState();
}

class _MarketMovementsScreenState extends State<MarketMovementsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService(ApiService());

  List<dynamic> _movements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _analyticsService.getMarketMovements();
      if (mounted) {
        setState(() {
          _movements = data;
          _isLoading = false;
        });
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

  double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  String? _formatDate(dynamic raw) {
    if (raw == null) return null;
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('EEE dd MMM · HH:mm').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

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
          'Market Movements',
          style: AppTextStyles.h3.copyWith(color: context.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.accentOrange.withValues(alpha: 0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: AppColors.accentOrange, size: 14),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: AppTextStyles.overline.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w700),
                ),
              ],
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
    if (_movements.isEmpty) return _buildEmpty();
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
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Padding(
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
                'Failed to load market data',
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
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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
                child: Icon(Icons.trending_flat_rounded,
                    color: context.iconInactive, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'No Market Movements',
                style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Market data will appear here once matches are available.',
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
        _buildHeader(),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'UPCOMING MATCHES',
              style: AppTextStyles.overline
                  .copyWith(color: context.textSecondary, letterSpacing: 2),
            ),
            const Spacer(),
            Text(
              '${_movements.length} matches',
              style: AppTextStyles.caption
                  .copyWith(color: context.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._movements.map((item) => _buildMovementCard(item)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentOrange.withValues(alpha: 0.15),
            const Color(0xFF6C63FF).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: AppColors.accentOrange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Real-time Odds Tracking',
                  style:
                      AppTextStyles.h4.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Market analysis & value bet detection',
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

  Widget _buildMovementCard(dynamic item) {
    final home =
        (item['homeTeam'] ?? item['home_team'] ?? 'Home').toString();
    final away =
        (item['awayTeam'] ?? item['away_team'] ?? 'Away').toString();
    final dateStr = _formatDate(
        item['matchDate'] ?? item['match_date'] ?? item['date']);
    final valueLabel =
        item['valueLabel'] ?? item['value_label'] ?? item['valueBet'];

    final homeOdds =
        _safeDouble(item['homeOdds'] ?? item['home_odds'] ?? item['odds1']);
    final drawOdds =
        _safeDouble(item['drawOdds'] ?? item['draw_odds'] ?? item['oddsX']);
    final awayOdds =
        _safeDouble(item['awayOdds'] ?? item['away_odds'] ?? item['odds2']);

    final homeProb =
        _safeDouble(item['homeProb'] ?? item['home_prob'] ?? item['prob1']);
    final drawProb =
        _safeDouble(item['drawProb'] ?? item['draw_prob'] ?? item['probX']);
    final awayProb =
        _safeDouble(item['awayProb'] ?? item['away_prob'] ?? item['prob2']);

    final hasValueBet = valueLabel != null &&
        valueLabel.toString().isNotEmpty &&
        valueLabel.toString() != 'null';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValueBet
              ? AppColors.accentOrange.withValues(alpha: 0.4)
              : context.borderSubtle,
          width: hasValueBet ? 1.5 : 1,
        ),
        boxShadow: hasValueBet
            ? [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: teams + value badge ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        home,
                        style: AppTextStyles.label
                            .copyWith(color: context.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'vs $away',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: context.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (hasValueBet) _buildValueBetBadge(valueLabel.toString()),
              ],
            ),
          ),

          // ── Match date ───────────────────────────────────────────────────
          if (dateStr != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 12, color: context.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: AppTextStyles.caption
                        .copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // ── Odds boxes ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildOddsBox(
                  label: '1',
                  subLabel: 'Home',
                  value: homeOdds,
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                _buildOddsBox(
                  label: 'X',
                  subLabel: 'Draw',
                  value: drawOdds,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 8),
                _buildOddsBox(
                  label: '2',
                  subLabel: 'Away',
                  value: awayOdds,
                  color: const Color(0xFF9D4EDD),
                ),
              ],
            ),
          ),

          // ── Probability bars ─────────────────────────────────────────────
          if (homeProb > 0 || drawProb > 0 || awayProb > 0) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                'Win Probabilities',
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: _buildProbabilityBars(
                homeProb: homeProb,
                drawProb: drawProb,
                awayProb: awayProb,
                homeLabel: '1',
                drawLabel: 'X',
                awayLabel: '2',
              ),
            ),
          ],

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildValueBetBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentOrange.withValues(alpha: 0.25),
            AppColors.accentOrange.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'VALUE BET 🔥',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w800,
              fontSize: 9.5,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOddsBox({
    required String label,
    required String subLabel,
    required double value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value > 0 ? value.toStringAsFixed(2) : '—',
              style: AppTextStyles.h4.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subLabel,
              style: AppTextStyles.caption.copyWith(
                color: context.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityBars({
    required double homeProb,
    required double drawProb,
    required double awayProb,
    required String homeLabel,
    required String drawLabel,
    required String awayLabel,
  }) {
    final total = homeProb + drawProb + awayProb;
    final safeDivide = total > 0 ? total : 1.0;
    final homeFrac = homeProb / safeDivide;
    final drawFrac = drawProb / safeDivide;
    final awayFrac = awayProb / safeDivide;

    return Column(
      children: [
        _buildSingleBar(
          label: homeLabel,
          fraction: homeFrac,
          pct: homeProb,
          color: const Color(0xFF4A90E2),
        ),
        const SizedBox(height: 7),
        _buildSingleBar(
          label: drawLabel,
          fraction: drawFrac,
          pct: drawProb,
          color: AppColors.accentOrange,
        ),
        const SizedBox(height: 7),
        _buildSingleBar(
          label: awayLabel,
          fraction: awayFrac,
          pct: awayProb,
          color: const Color(0xFF9D4EDD),
        ),
      ],
    );
  }

  Widget _buildSingleBar({
    required String label,
    required double fraction,
    required double pct,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * fraction.clamp(0.0, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 8,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${pct.toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
