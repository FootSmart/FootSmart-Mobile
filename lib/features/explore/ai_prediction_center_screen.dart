import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/services/analytics_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';

class AIPredictionCenterScreen extends StatefulWidget {
  const AIPredictionCenterScreen({super.key});

  @override
  State<AIPredictionCenterScreen> createState() =>
      _AIPredictionCenterScreenState();
}

class _AIPredictionCenterScreenState extends State<AIPredictionCenterScreen> {
  final AnalyticsService _analyticsService = AnalyticsService(ApiService());

  List<dynamic> _predictions = [];
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
      final data = await _analyticsService.getPredictions(limit: 20);
      if (mounted) {
        setState(() {
          _predictions = data;
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

  String _confidenceLevel(dynamic item) {
    final raw = (item['confidenceLevel'] ?? item['confidence_level'] ?? '')
        .toString()
        .toUpperCase();
    if (raw == 'HIGH' || raw == 'MEDIUM' || raw == 'LOW') return raw;
    final pct =
        _safeDouble(item['confidence'] ?? item['confidencePct'] ?? item['confidence_pct']);
    if (pct >= 70) return 'HIGH';
    if (pct >= 45) return 'MEDIUM';
    return 'LOW';
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'HIGH':
        return AppColors.accentGreen;
      case 'MEDIUM':
        return AppColors.accentOrange;
      default:
        return AppColors.betLoss;
    }
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'HIGH':
        return 'HIGH CONFIDENCE';
      case 'MEDIUM':
        return 'MEDIUM';
      default:
        return 'LOW';
    }
  }

  IconData _levelIcon(String level) {
    switch (level) {
      case 'HIGH':
        return Icons.verified_rounded;
      case 'MEDIUM':
        return Icons.trending_up_rounded;
      default:
        return Icons.warning_amber_rounded;
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
          'AI Prediction Center',
          style: AppTextStyles.h3.copyWith(color: context.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology_outlined,
                    color: AppColors.accentGreen, size: 14),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: AppTextStyles.overline.copyWith(
                      color: AppColors.accentGreen, fontWeight: FontWeight.w700),
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
    if (_predictions.isEmpty) return _buildEmpty();
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
                color: AppColors.betLoss.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppColors.betLoss, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load predictions',
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
              label: const Text('Try Again'),
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
              child: Icon(Icons.psychology_outlined,
                  color: context.iconInactive, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'No Predictions Available',
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'AI predictions will appear here once matches are scheduled.',
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        _buildBanner(),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'PREDICTIONS',
              style: AppTextStyles.overline
                  .copyWith(color: context.textSecondary, letterSpacing: 2),
            ),
            const Spacer(),
            Text(
              '${_predictions.length} matches',
              style:
                  AppTextStyles.caption.copyWith(color: context.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._predictions.map((item) => _buildPredictionCard(item)),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGreen.withOpacity(0.18),
            const Color(0xFF6C63FF).withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.accentGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Prediction Center',
                  style: AppTextStyles.h4.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Machine learning powered match predictions',
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

  Widget _buildPredictionCard(dynamic item) {
    final home =
        (item['homeTeam'] ?? item['home_team'] ?? 'Home').toString();
    final away =
        (item['awayTeam'] ?? item['away_team'] ?? 'Away').toString();
    final prediction =
        (item['prediction'] ?? item['predictedOutcome'] ?? item['predicted_outcome'] ?? 'N/A')
            .toString();
    final confidence = _safeDouble(
        item['confidence'] ?? item['confidencePct'] ?? item['confidence_pct']);
    final level = _confidenceLevel(item);
    final levelColor = _levelColor(level);

    final homeOdds = _safeDouble(item['homeOdds'] ?? item['home_odds'] ?? item['odds1']);
    final drawOdds = _safeDouble(item['drawOdds'] ?? item['draw_odds'] ?? item['oddsX']);
    final awayOdds = _safeDouble(item['awayOdds'] ?? item['away_odds'] ?? item['odds2']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          // ── Top: Level badge + Teams ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$home vs $away',
                    style: AppTextStyles.label
                        .copyWith(color: context.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildLevelBadge(level, levelColor),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Prediction label ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(_levelIcon(level), color: levelColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    prediction,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: levelColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Confidence bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confidence',
                      style: AppTextStyles.caption
                          .copyWith(color: context.textSecondary),
                    ),
                    Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                          color: levelColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth =
                        constraints.maxWidth * (confidence.clamp(0, 100) / 100);
                    return Stack(
                      children: [
                        Container(
                          height: 7,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 7,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: levelColor,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: levelColor.withOpacity(0.4),
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
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Odds row ─────────────────────────────────────────────────────
          if (homeOdds > 0 || drawOdds > 0 || awayOdds > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  _buildOddsBox(
                    label: '1',
                    value: homeOdds,
                    color: const Color(0xFF4A90E2),
                    flex: 1,
                  ),
                  const SizedBox(width: 8),
                  _buildOddsBox(
                    label: 'X',
                    value: drawOdds,
                    color: AppColors.accentOrange,
                    flex: 1,
                  ),
                  const SizedBox(width: 8),
                  _buildOddsBox(
                    label: '2',
                    value: awayOdds,
                    color: const Color(0xFF9D4EDD),
                    flex: 1,
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String level, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_levelIcon(level), color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            _levelLabel(level),
            style: AppTextStyles.overline.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOddsBox({
    required String label,
    required double value,
    required Color color,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              value > 0 ? value.toStringAsFixed(2) : '—',
              style: AppTextStyles.label.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
