import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/services/analytics_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService(ApiService());
  final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  Map<String, dynamic>? _data;
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
      final data = await _analyticsService.getUserStats();
      if (mounted) {
        setState(() {
          _data = data;
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  String _formatCurrency(double value) => _currencyFmt.format(value);

  String _formatPct(double value) => '${value.toStringAsFixed(1)}%';

  // ── Build ──────────────────────────────────────────────────────────────────

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
          'Analytics Dashboard',
          style: AppTextStyles.h3.copyWith(color: context.textPrimary),
        ),
        centerTitle: true,
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
    if (_data == null || _data!.isEmpty) return _buildEmpty();
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
              'Failed to load dashboard',
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
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
    return Center(
      child: Padding(
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
              child: Icon(Icons.bar_chart_rounded,
                  color: context.iconInactive, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'No Data Yet',
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Place your first bet to see analytics here.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;

    // ── Core stats ──────────────────────────────────────────────────────────
    final totalBets = _safeInt(d['totalBets'] ?? d['total_bets']);
    final wonBets = _safeInt(d['wonBets'] ?? d['won_bets'] ?? d['won']);
    final lostBets = _safeInt(d['lostBets'] ?? d['lost_bets'] ?? d['lost']);
    final pendingBets =
        _safeInt(d['pendingBets'] ?? d['pending_bets'] ?? d['pending']);
    final winRate = _safeDouble(d['winRate'] ?? d['win_rate']);
    final roi = _safeDouble(d['roi'] ?? d['ROI']);
    final balance = _safeDouble(d['balance'] ?? d['currentBalance'] ?? d['current_balance']);
    final totalStaked =
        _safeDouble(d['totalStaked'] ?? d['total_staked'] ?? d['totalWagered']);
    final totalReturned =
        _safeDouble(d['totalReturned'] ?? d['total_returned'] ?? d['totalWon']);
    final avgStake = _safeDouble(d['avgStake'] ?? d['avg_stake']);
    final avgOdds = _safeDouble(d['avgOdds'] ?? d['avg_odds']);
    final bestWin = _safeDouble(d['bestWin'] ?? d['best_win'] ?? d['biggestWin']);
    final username = (d['username'] ?? d['firstName'] ?? d['name'] ?? 'Bettor')
        .toString();

    // ── Recent form ─────────────────────────────────────────────────────────
    final formRaw = d['recentForm'] ?? d['recent_form'] ?? d['form'];
    List<String> recentForm = [];
    if (formRaw is List) {
      recentForm = formRaw.map((e) => e.toString().toUpperCase()).toList();
    } else if (formRaw is String) {
      recentForm = formRaw.split('').map((e) => e.toUpperCase()).toList();
    }

    // ── Selection stats ──────────────────────────────────────────────────────
    final selStats =
        d['selectionStats'] ?? d['selection_stats'] ?? d['bySelection'] ?? {};
    final homeStats = selStats['home'] ?? selStats['HOME'] ?? {};
    final drawStats = selStats['draw'] ?? selStats['DRAW'] ?? {};
    final awayStats = selStats['away'] ?? selStats['AWAY'] ?? {};

    // ── Monthly stats ────────────────────────────────────────────────────────
    final monthlyRaw =
        d['monthlyStats'] ?? d['monthly_stats'] ?? d['monthly'] ?? [];
    List<dynamic> monthlyStats = monthlyRaw is List ? monthlyRaw : [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // ── Greeting / balance card ────────────────────────────────────────
        _buildGreetingCard(username, balance, totalStaked, totalReturned),
        const SizedBox(height: 20),

        // ── KPI row ─────────────────────────────────────────────────────────
        _buildSectionLabel('PERFORMANCE OVERVIEW'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildKpiPill(
              label: 'Total Bets',
              value: totalBets.toString(),
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF4A90E2),
            ),
            const SizedBox(width: 10),
            _buildKpiPill(
              label: 'Win Rate',
              value: _formatPct(winRate),
              icon: Icons.percent_rounded,
              color: AppColors.accentGreen,
            ),
            const SizedBox(width: 10),
            _buildKpiPill(
              label: 'ROI',
              value: '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
              icon: Icons.trending_up_rounded,
              color: roi >= 0 ? AppColors.accentGreen : AppColors.betLoss,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Won / Lost / Pending ─────────────────────────────────────────────
        _buildSectionLabel('BET BREAKDOWN'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                label: 'Won',
                count: wonBets,
                icon: Icons.check_circle_rounded,
                color: AppColors.betWin,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                label: 'Lost',
                count: lostBets,
                icon: Icons.cancel_rounded,
                color: AppColors.betLoss,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                label: 'Pending',
                count: pendingBets,
                icon: Icons.schedule_rounded,
                color: AppColors.betDraw,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Recent Form ──────────────────────────────────────────────────────
        if (recentForm.isNotEmpty) ...[
          _buildSectionLabel('RECENT FORM'),
          const SizedBox(height: 12),
          _buildRecentForm(recentForm),
          const SizedBox(height: 20),
        ],

        // ── Selection stats ──────────────────────────────────────────────────
        _buildSectionLabel('STATS BY SELECTION'),
        const SizedBox(height: 12),
        _buildSelectionStatsTable(
          homeStats: homeStats,
          drawStats: drawStats,
          awayStats: awayStats,
        ),
        const SizedBox(height: 20),

        // ── Monthly bars ─────────────────────────────────────────────────────
        if (monthlyStats.isNotEmpty) ...[
          _buildSectionLabel('MONTHLY STATS'),
          const SizedBox(height: 12),
          _buildMonthlyBars(monthlyStats),
          const SizedBox(height: 20),
        ],

        // ── Misc stats ────────────────────────────────────────────────────────
        _buildSectionLabel('AVERAGES & BESTS'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiscCard(
                label: 'Avg Stake',
                value: _formatCurrency(avgStake),
                icon: Icons.payments_rounded,
                color: const Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiscCard(
                label: 'Avg Odds',
                value: avgOdds.toStringAsFixed(2),
                icon: Icons.calculate_rounded,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiscCard(
                label: 'Best Win',
                value: _formatCurrency(bestWin),
                icon: Icons.emoji_events_rounded,
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.overline
          .copyWith(color: context.textSecondary, letterSpacing: 2),
    );
  }

  Widget _buildGreetingCard(
    String username,
    double balance,
    double staked,
    double returned,
  ) {
    final pnl = returned - staked;
    final isPositive = pnl >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGreen.withValues(alpha: 0.18),
            const Color(0xFF6C63FF).withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.accentGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $username 👋',
                      style: AppTextStyles.h4
                          .copyWith(color: context.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Here\'s your betting summary',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceTile(
                  label: 'Balance',
                  value: _formatCurrency(balance),
                  valueColor: context.textPrimary,
                ),
              ),
              Container(
                  width: 1, height: 40, color: context.borderSubtle),
              Expanded(
                child: _buildBalanceTile(
                  label: 'Total P&L',
                  value:
                      '${isPositive ? '+' : ''}${_formatCurrency(pnl)}',
                  valueColor: isPositive
                      ? AppColors.accentGreen
                      : AppColors.betLoss,
                  center: true,
                ),
              ),
              Container(
                  width: 1, height: 40, color: context.borderSubtle),
              Expanded(
                child: _buildBalanceTile(
                  label: 'Staked',
                  value: _formatCurrency(staked),
                  valueColor: context.textPrimary,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTile({
    required String label,
    required String value,
    required Color valueColor,
    bool center = false,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : align,
      children: [
        Text(
          label,
          style:
              AppTextStyles.caption.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildKpiPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: context.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentForm(List<String> form) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Last ${form.length} bets',
                style: AppTextStyles.label.copyWith(color: context.textPrimary),
              ),
              const Spacer(),
              // Win count
              _buildFormSummary(form),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: form.map((r) => _buildFormPill(r)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSummary(List<String> form) {
    final wins = form.where((e) => e == 'W').length;
    final losses = form.where((e) => e == 'L').length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFormCount('W', wins, AppColors.betWin),
        const SizedBox(width: 8),
        _buildFormCount('L', losses, AppColors.betLoss),
      ],
    );
  }

  Widget _buildFormCount(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count$label',
        style: AppTextStyles.overline.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFormPill(String result) {
    final isWin = result == 'W';
    final isDraw = result == 'D';
    final color = isWin
        ? AppColors.betWin
        : isDraw
            ? AppColors.betDraw
            : AppColors.betLoss;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        result,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelectionStatsTable({
    required dynamic homeStats,
    required dynamic drawStats,
    required dynamic awayStats,
  }) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            stats: homeStats,
          ),
          Divider(height: 1, color: context.borderSubtle, indent: 16),
          _buildSelRow(
            label: 'DRAW',
            icon: Icons.horizontal_rule_rounded,
            color: AppColors.betDraw,
            stats: drawStats,
          ),
          Divider(height: 1, color: context.borderSubtle, indent: 16),
          _buildSelRow(
            label: 'AWAY',
            icon: Icons.flight_land_rounded,
            color: const Color(0xFF9D4EDD),
            stats: awayStats,
          ),
        ],
      ),
    );
  }

  Widget _buildSelRow({
    required String label,
    required IconData icon,
    required Color color,
    required dynamic stats,
  }) {
    final bets = _safeInt(stats is Map
        ? (stats['totalBets'] ?? stats['total'] ?? stats['count'])
        : null);
    final rate = _safeDouble(stats is Map
        ? (stats['winRate'] ?? stats['win_rate'] ?? stats['rate'])
        : null);
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
          // Bets count
          Expanded(
            flex: 2,
            child: Text(
              bets.toString(),
              style: AppTextStyles.label.copyWith(color: context.textPrimary),
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
                  _formatPct(rate),
                  style: AppTextStyles.label.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final barW =
                        constraints.maxWidth * (rate.clamp(0, 100) / 100);
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

  Widget _buildMonthlyBars(List<dynamic> months) {
    // Find max value for scale
    double maxVal = 1;
    for (final m in months) {
      if (m is! Map) continue;
      final staked =
          _safeDouble(m['totalStaked'] ?? m['staked'] ?? m['wagered']);
      final returned =
          _safeDouble(m['totalReturned'] ?? m['returned'] ?? m['won']);
      if (staked > maxVal) maxVal = staked;
      if (returned > maxVal) maxVal = returned;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
              _buildLegendDot(context.textSecondary.withValues(alpha: 0.5), 'Staked'),
            ],
          ),
          const SizedBox(height: 20),
          // Bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.take(6).map((m) {
              if (m is! Map) return const SizedBox(width: 8);
              final label =
                  (m['month'] ?? m['label'] ?? m['period'] ?? '').toString();
              final staked =
                  _safeDouble(m['totalStaked'] ?? m['staked'] ?? m['wagered']);
              final returned = _safeDouble(
                  m['totalReturned'] ?? m['returned'] ?? m['won']);
              return Expanded(
                child: _buildMonthColumn(
                  label: label.length > 3 ? label.substring(0, 3) : label,
                  staked: staked,
                  returned: returned,
                  maxVal: maxVal,
                ),
              );
            }).toList(),
          ),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: context.textSecondary),
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
    const maxHeight = 100.0;
    final stakedH = maxVal > 0 ? (staked / maxVal) * maxHeight : 0.0;
    final retH = maxVal > 0 ? (returned / maxVal) * maxHeight : 0.0;
    final isProfit = returned >= staked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bars side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Staked bar
              Container(
                width: 10,
                height: stakedH.clamp(2, maxHeight),
                decoration: BoxDecoration(
                  color: context.textSecondary.withValues(alpha: 0.35),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3)),
                ),
              ),
              const SizedBox(width: 2),
              // Returned bar
              Container(
                width: 10,
                height: retH.clamp(2, maxHeight),
                decoration: BoxDecoration(
                  color: isProfit
                      ? AppColors.accentGreen
                      : AppColors.betLoss,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3)),
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
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMiscCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
