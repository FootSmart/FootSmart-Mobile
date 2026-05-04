import 'dart:async';

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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<dynamic> _predictions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  final int _pageSize = 10;
  int _total = 0;
  int _totalPages = 1;
  bool _hasMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || _isLoading) return;
    if (!_hasMore) return;
    if (_scrollController.position.extentAfter < 240) {
      _loadData(reset: false);
    }
  }

  Future<void> _loadData({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _error = null;
        _page = 1;
        _total = 0;
        _totalPages = 1;
        _hasMore = false;
        _predictions = [];
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }
    try {
      final pageToLoad = reset ? 1 : _page + 1;
      final data = await _analyticsService.getMatchPredictions(
        search: _searchQuery,
        page: pageToLoad,
        pageSize: _pageSize,
      );
      final items = (data['data'] as List?) ?? [];
      final total = (data['total'] as num?)?.toInt() ?? 0;
      final totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
      if (mounted) {
        setState(() {
          _predictions = reset ? items : [..._predictions, ...items];
          _total = total;
          _totalPages = totalPages;
          _page = pageToLoad;
          _hasMore = _page < _totalPages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = value.trim();
      if (query == _searchQuery) return;
      setState(() => _searchQuery = query);
      _loadData(reset: true);
    });
  }

  double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  double _toPct(double value) {
    if (value <= 1.0) return value * 100;
    return value;
  }

  String _confidenceLevel(dynamic item) {
    final raw = (item['confidenceLevel'] ?? item['confidence_level'] ?? '')
        .toString()
        .toUpperCase();
    if (raw == 'HIGH' || raw == 'MEDIUM' || raw == 'LOW') return raw;
    final pct = _toPct(_safeDouble(item['confidence'] ??
      item['confidencePct'] ??
      item['confidence_pct'] ??
      item['confidenceScore'] ??
      item['confidence_score']));
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
              color: AppColors.accentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.3), width: 1),
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
        onRefresh: () => _loadData(reset: true),
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
      child: SingleChildScrollView(
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
              onPressed: () => _loadData(reset: true),
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
      child: SingleChildScrollView(
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
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        _buildBanner(),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'PREDICTIONS',
              style: AppTextStyles.overline
                  .copyWith(color: context.textSecondary, letterSpacing: 2),
            ),
            const Spacer(),
            Text(
              '${_predictions.length} of $_total',
              style:
                  AppTextStyles.caption.copyWith(color: context.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._predictions.map((item) => _buildPredictionCard(item)),
        const SizedBox(height: 12),
        _buildPaginationFooter(),
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
            AppColors.accentGreen.withValues(alpha: 0.18),
            const Color(0xFF6C63FF).withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
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
                  'Latest match predictions with confidence scores',
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.iconInactive, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search team name (ex: esp)',
                hintStyle:
                    AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: context.iconInactive, size: 18),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
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
    final mostLikelyScore =
        (item['mostLikelyScore'] ?? item['most_likely_score'] ?? 'N/A')
            .toString();
    final confidence = _toPct(_safeDouble(item['confidenceScore'] ??
        item['confidence_score'] ??
        item['confidence'] ??
        item['confidencePct'] ??
      item['confidence_pct']));
    final homeProb = _safeDouble(
      item['homeWinProb'] ?? item['home_win_prob'] ?? item['homeProb']);
    final drawProb = _safeDouble(item['drawProb'] ?? item['draw_prob']);
    final awayProb = _safeDouble(
      item['awayWinProb'] ?? item['away_win_prob'] ?? item['awayProb']);
    final homeProbPct = _toPct(homeProb);
    final drawProbPct = _toPct(drawProb);
    final awayProbPct = _toPct(awayProb);
    final level = _confidenceLevel(item);
    final levelColor = _levelColor(level);
    final predictionLabel = _bestPredictionLabel(
      home: home,
      away: away,
      homeProb: homeProbPct,
      drawProb: drawProbPct,
      awayProb: awayProbPct,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(_levelIcon(level), color: levelColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    predictionLabel,
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
                            color: levelColor.withValues(alpha: 0.12),
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
                                color: levelColor.withValues(alpha: 0.4),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROBABILITIES',
                  style: AppTextStyles.overline.copyWith(
                    color: context.textSecondary,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildProbBox(
                      label: 'HOME',
                      value: homeProbPct,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(width: 8),
                    _buildProbBox(
                      label: 'DRAW',
                      value: drawProbPct,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 8),
                    _buildProbBox(
                      label: 'AWAY',
                      value: awayProbPct,
                      color: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Icon(Icons.scoreboard_rounded,
                    color: context.iconInactive, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Most likely score',
                  style: AppTextStyles.caption
                      .copyWith(color: context.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.borderSubtle),
                  ),
                  child: Text(
                    mostLikelyScore,
                    style: AppTextStyles.label.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bestPredictionLabel({
    required String home,
    required String away,
    required double homeProb,
    required double drawProb,
    required double awayProb,
  }) {
    if (homeProb >= drawProb && homeProb >= awayProb) return '$home Win';
    if (drawProb >= homeProb && drawProb >= awayProb) return 'Draw';
    return '$away Win';
  }

  Widget _buildLevelBadge(String level, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
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

  Widget _buildProbBox({
    required String label,
    required double value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(1)}%',
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

  Widget _buildPaginationFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.accentGreen,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_hasMore) {
      return Center(
        child: OutlinedButton.icon(
          onPressed: () => _loadData(reset: false),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          label: const Text('Load more'),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.textPrimary,
            side: BorderSide(color: context.borderSubtle),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return Center(
      child: Text(
        'No more results',
        style: AppTextStyles.caption.copyWith(color: context.textSecondary),
      ),
    );
  }
}
