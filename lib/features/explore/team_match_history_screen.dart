import 'package:flutter/material.dart';
import '../../core/models/match.dart';
import '../../core/services/api_service.dart';
import '../../core/services/match_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';

/// Displays the full finished-match history for a club/team.
///
/// - Scores come from [FootballMatch.homeGoals] / [FootballMatch.awayGoals]
///   (real DB columns). [externalId] is NEVER parsed to infer result/status.
/// - Status is determined by [FootballMatch.status] and [FootballMatch.result].
class TeamMatchHistoryScreen extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamMatchHistoryScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<TeamMatchHistoryScreen> createState() => _TeamMatchHistoryScreenState();
}

class _TeamMatchHistoryScreenState extends State<TeamMatchHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final MatchService _matchService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<FootballMatch> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _matchService = MatchService(ApiService());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final matches = await _matchService.getTeamMatchHistory(
        widget.teamId,
        limit: 30,
      );
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
      _animationController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.accent.withValues(alpha: 0.18),
            context.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.accent,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Shield icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.accent, context.accent.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: context.accent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.history, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.teamName,
                  style: AppTextStyles.h3.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Match History',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading && _matches.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.accent.withValues(alpha: 0.4)),
              ),
              child: Text(
                '${_matches.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    if (_matches.isEmpty) return _buildEmptyState();
    return _buildMatchList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading match history…',
            style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 56),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load match history',
              style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: context.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No finished matches found',
              style: AppTextStyles.h3.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Previous results for ${widget.teamName} will appear here.',
              style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _matches.length,
        itemBuilder: (context, index) => _buildMatchCard(_matches[index]),
      ),
    );
  }

  // ─── Match card ───────────────────────────────────────────────────────────

  Widget _buildMatchCard(FootballMatch match) {
    final isHome = match.homeTeam.id == widget.teamId;
    final highlightColor = context.accent;

    // Score from real DB columns — never external_id
    final homeScore = match.homeGoals;
    final awayScore = match.awayGoals;

    // Outcome from the team's perspective (using real result field)
    final outcome = _resolveOutcome(match, isHome);
    final outcomeColor = _outcomeColor(outcome);
    final outcomeLabel = _outcomeLabel(outcome);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardBg,
            context.cardBg.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.accent.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top bar: league + date ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 13, color: context.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    match.leagueName ?? 'Unknown League',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: context.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(match.matchDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // ── Main row: teams + score ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Home team
                Expanded(
                  child: _buildTeamCell(
                    name: match.homeTeam.name,
                    logo: match.homeTeam.logo,
                    highlight: match.homeTeam.id == widget.teamId,
                    highlightColor: highlightColor,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                // Score block
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        outcomeColor.withValues(alpha: 0.2),
                        outcomeColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: outcomeColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$homeScore – $awayScore',
                        style: AppTextStyles.h3.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: outcomeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          outcomeLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: outcomeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Away team
                Expanded(
                  child: _buildTeamCell(
                    name: match.awayTeam.name,
                    logo: match.awayTeam.logo,
                    highlight: match.awayTeam.id == widget.teamId,
                    highlightColor: highlightColor,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),
          // ── Bottom: half-time + status badge ──────────────────
          if (match.htHomeGoals != null || match.htAwayGoals != null)
            Container(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_bottom,
                      size: 12, color: context.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'HT: ${match.htHomeGoals ?? 0} – ${match.htAwayGoals ?? 0}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamCell({
    required String name,
    required String? logo,
    required bool highlight,
    required Color highlightColor,
    required CrossAxisAlignment align,
  }) {
    final isRight = align == CrossAxisAlignment.end;
    return Column(
      crossAxisAlignment: align,
      children: [
        if (logo != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              logo,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.shield,
                size: 28,
                color:
                    highlight ? highlightColor : context.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          Icon(
            Icons.shield,
            size: 28,
            color: highlight ? highlightColor : context.textSecondary.withValues(alpha: 0.5),
          ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTextStyles.bodySmall.copyWith(
            color: highlight ? highlightColor : context.textPrimary,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
          textAlign: isRight ? TextAlign.end : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Outcome from the perspective of the selected team.
  /// Uses real [match.result] field ('H', 'D', 'A'), never external_id.
  String _resolveOutcome(FootballMatch match, bool isHome) {
    final result = match.result;
    if (result == null || result.isEmpty) {
      // Fallback to goal comparison
      final hg = match.homeGoals;
      final ag = match.awayGoals;
      if (hg == ag) return 'D';
      if ((isHome && hg > ag) || (!isHome && ag > hg)) return 'W';
      return 'L';
    }
    // result field is from home team's perspective: 'H'=home win, 'A'=away win
    if (result == 'D') return 'D';
    if (result == 'H') return isHome ? 'W' : 'L';
    if (result == 'A') return isHome ? 'L' : 'W';
    return result;
  }

  Color _outcomeColor(String outcome) {
    switch (outcome) {
      case 'W':
        return const Color(0xFF00D9A3); // green-teal
      case 'L':
        return AppColors.error;
      default:
        return const Color(0xFFFFB74D); // amber for draw
    }
  }

  String _outcomeLabel(String outcome) {
    switch (outcome) {
      case 'W':
        return 'WIN';
      case 'L':
        return 'LOSS';
      default:
        return 'DRAW';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
