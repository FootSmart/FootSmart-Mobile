import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/services/analytics_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';

class AdvancedMatchInsightsScreen extends StatefulWidget {
  const AdvancedMatchInsightsScreen({super.key});

  @override
  State<AdvancedMatchInsightsScreen> createState() =>
      _AdvancedMatchInsightsScreenState();
}

class _AdvancedMatchInsightsScreenState
    extends State<AdvancedMatchInsightsScreen> {
  final AnalyticsService _analyticsService =
      AnalyticsService(ApiService());

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
      final data = await _analyticsService.getMatchInsights(limit: 30);
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

  double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  List<dynamic> _recentMatches() {
    if (_data == null) return [];
    final raw = _data!['recentMatches'] ?? _data!['matches'] ?? [];
    if (raw is List) return raw;
    return [];
  }

  String _resultBadge(dynamic match) {
    final result = (match['result'] ?? '').toString().toUpperCase();
    if (result == 'H' || result == 'HOME') return 'H';
    if (result == 'D' || result == 'DRAW') return 'D';
    if (result == 'A' || result == 'AWAY') return 'A';
    // Infer from score
    final home = _safeDouble(match['homeScore'] ?? match['home_score']);
    final away = _safeDouble(match['awayScore'] ?? match['away_score']);
    if (home > away) return 'H';
    if (home == away) return 'D';
    return 'A';
  }

  Color _resultColor(String badge) {
    switch (badge) {
      case 'H':
        return AppColors.accentGreen;
      case 'D':
        return AppColors.betDraw;
      default:
        return AppColors.betLoss;
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
          'Match Insights',
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
            const Icon(Icons.error_outline_rounded,
                color: AppColors.betLoss, size: 56),
            const SizedBox(height: 16),
            Text(
              'Failed to load insights',
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              color: context.iconInactive, size: 56),
          const SizedBox(height: 16),
          Text(
            'No insights available',
            style: AppTextStyles.h4.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final stats = _data!['stats'] ?? _data!['overview'] ?? _data!;
    final homeWin = _safeDouble(stats['homeWinPct'] ?? stats['homeWin'] ??
        stats['home_win_pct']);
    final draw = _safeDouble(stats['drawPct'] ?? stats['draw'] ??
        stats['draw_pct']);
    final awayWin = _safeDouble(stats['awayWinPct'] ?? stats['awayWin'] ??
        stats['away_win_pct']);
    final over25 = _safeDouble(stats['over25Pct'] ?? stats['over25'] ??
        stats['over_2_5_pct']);
    final btts = _safeDouble(
        stats['bttsPct'] ?? stats['btts'] ?? stats['btts_pct']);
    final matches = _recentMatches();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _buildHeader(),
        const SizedBox(height: 24),

        // ── KPI Grid 2x2 ───────────────────────────────────────────────────
        Text(
          'SEASON OVERVIEW',
          style: AppTextStyles.overline
              .copyWith(color: context.textSecondary, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _buildKpiCard(
              label: 'Home Win',
              value: homeWin,
              icon: Icons.home_rounded,
              color: AppColors.accentGreen,
            ),
            _buildKpiCard(
              label: 'Draw',
              value: draw,
              icon: Icons.horizontal_rule_rounded,
              color: AppColors.betDraw,
            ),
            _buildKpiCard(
              label: 'Away Win',
              value: awayWin,
              icon: Icons.flight_land_rounded,
              color: const Color(0xFF6C63FF),
            ),
            _buildKpiCard(
              label: 'Over 2.5 Goals',
              value: over25,
              icon: Icons.sports_soccer_rounded,
              color: AppColors.accentOrange,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── BTTS Card ───────────────────────────────────────────────────────
        _buildBttsCard(btts),
        const SizedBox(height: 28),

        // ── Recent Matches ──────────────────────────────────────────────────
        if (matches.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'RECENT MATCHES',
                style: AppTextStyles.overline
                    .copyWith(color: context.textSecondary, letterSpacing: 2),
              ),
              const Spacer(),
              Text(
                '${matches.length} results',
                style:
                    AppTextStyles.caption.copyWith(color: context.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...matches.map((m) => _buildMatchRow(m)),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.timeline_rounded,
                color: AppColors.accentGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Match Insights',
                  style:
                      AppTextStyles.h4.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deep dive into match statistics & patterns',
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

  Widget _buildKpiCard({
    required String label,
    required double value,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}%',
                  style: AppTextStyles.overline.copyWith(
                      color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value.clamp(0, 100) / 100),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBttsCard(double btts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_horiz_rounded,
                color: Color(0xFF4A90E2), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Both Teams To Score (BTTS)',
                  style: AppTextStyles.label
                      .copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: btts.clamp(0, 100) / 100,
                    backgroundColor:
                        const Color(0xFF4A90E2).withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A90E2)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${btts.toStringAsFixed(1)}%',
            style: AppTextStyles.h3.copyWith(color: const Color(0xFF4A90E2)),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRow(dynamic match) {
    final home = match['homeTeam'] ?? match['home_team'] ?? 'Home';
    final away = match['awayTeam'] ?? match['away_team'] ?? 'Away';
    final homeScore =
        match['homeScore'] ?? match['home_score'] ?? match['scoreHome'] ?? '-';
    final awayScore =
        match['awayScore'] ?? match['away_score'] ?? match['scoreAway'] ?? '-';
    final dateRaw =
        match['date'] ?? match['matchDate'] ?? match['played_at'];
    String dateStr = '';
    if (dateRaw != null) {
      try {
        final dt = DateTime.parse(dateRaw.toString());
        dateStr = DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {
        dateStr = dateRaw.toString();
      }
    }
    final badge = _resultBadge(match);
    final badgeColor = _resultColor(badge);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          // Result badge
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: AppTextStyles.label.copyWith(
                  color: badgeColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Teams
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$home vs $away',
                  style:
                      AppTextStyles.label.copyWith(color: context.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: AppTextStyles.caption
                        .copyWith(color: context.textSecondary),
                  ),
              ],
            ),
          ),
          // Score
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.surfaceBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$homeScore – $awayScore',
              style: AppTextStyles.label.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
