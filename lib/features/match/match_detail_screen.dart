import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';
import '../../core/models/match.dart';
import '../../core/models/team.dart';
import '../../core/services/api_service.dart';
import '../../core/services/match_service.dart';
import '../../core/services/team_service.dart';

class MatchDetailScreen extends StatefulWidget {
  final FootballMatch match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final MatchService _matchService;
  late final TeamService _teamService;
  late final TabController _tabController;

  TeamForm? _homeForm;
  TeamForm? _awayForm;
  TeamStats? _homeStats;
  TeamStats? _awayStats;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final api = ApiService();
    _matchService = MatchService(api);
    _teamService = TeamService(api);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final homeId = widget.match.homeTeam.id;
      final awayId = widget.match.awayTeam.id;

      final results = await Future.wait([
        _matchService.getTeamForm(homeId, last: 5),
        _matchService.getTeamForm(awayId, last: 5),
        _teamService.getTeamStats(homeId),
        _teamService.getTeamStats(awayId),
      ]);

      if (mounted) {
        setState(() {
          _homeForm = results[0] as TeamForm;
          _awayForm = results[1] as TeamForm;
          _homeStats = results[2] as TeamStats;
          _awayStats = results[3] as TeamStats;
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

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
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
          match.leagueName ?? 'Match Details',
          style: AppTextStyles.h4.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.accent,
          unselectedLabelColor: context.textSecondary,
          indicatorColor: context.accent,
          indicatorWeight: 2,
          labelStyle: AppTextStyles.bodySmall
              .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Match header card ─────────────────────────────────────────────
          _MatchHeaderCard(match: match),
          const SizedBox(height: 8),
          // ── Tabs ──────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: context.accent),
                  )
                : _error != null
                    ? _ErrorView(
                        error: _error!,
                        onRetry: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadData();
                        },
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Overview tab
                          _OverviewTab(
                            match: match,
                            homeForm: _homeForm,
                            awayForm: _awayForm,
                          ),
                          // Stats tab
                          _StatsTab(
                            match: match,
                            homeStats: _homeStats,
                            awayStats: _awayStats,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Match Header Card ────────────────────────────────────────────────────────

class _MatchHeaderCard extends StatelessWidget {
  final FootballMatch match;
  const _MatchHeaderCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final date = match.matchDate;
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : '—';
    final timeStr = match.matchTime ??
        (date != null
            ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
            : '—');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.accent.withValues(alpha: 0.15),
            context.cardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Date & time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: context.textSecondary, size: 14),
              const SizedBox(width: 6),
              Text(
                '$dateStr  •  $timeStr',
                style: AppTextStyles.bodySmall
                    .copyWith(color: context.textSecondary),
              ),
              if (match.venue != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.location_on_outlined,
                    color: context.textSecondary, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    match.venue!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: context.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // Teams row
          Row(
            children: [
              // Home team
              Expanded(
                child: Column(
                  children: [
                    _TeamLogo(logoUrl: match.homeTeam.logo, size: 64),
                    const SizedBox(height: 10),
                    Text(
                      match.homeTeam.name,
                      style: AppTextStyles.h4.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Home',
                      style: AppTextStyles.caption
                          .copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              // VS badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'VS',
                      style: AppTextStyles.h3.copyWith(
                        color: context.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(match.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabel(match.status),
                        style: AppTextStyles.caption.copyWith(
                          color: _statusColor(match.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Away team
              Expanded(
                child: Column(
                  children: [
                    _TeamLogo(logoUrl: match.awayTeam.logo, size: 64),
                    const SizedBox(height: 10),
                    Text(
                      match.awayTeam.name,
                      style: AppTextStyles.h4.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Away',
                      style: AppTextStyles.caption
                          .copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (match.matchday != null) ...[
            const SizedBox(height: 12),
            Text(
              'Matchday ${match.matchday}',
              style:
                  AppTextStyles.caption.copyWith(color: context.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'live':
        return AppColors.error;
      case 'finished':
        return AppColors.textGrey;
      default:
        return AppColors.accentGreen;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'live':
        return 'LIVE';
      case 'finished':
        return 'FINISHED';
      default:
        return 'UPCOMING';
    }
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final FootballMatch match;
  final TeamForm? homeForm;
  final TeamForm? awayForm;

  const _OverviewTab({
    required this.match,
    required this.homeForm,
    required this.awayForm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Form section
          Text(
            'Recent Form (Last 5)',
            style: AppTextStyles.h4.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Home form
              Expanded(
                child: _FormCard(
                  teamName: match.homeTeam.name,
                  form: homeForm,
                  isHome: true,
                ),
              ),
              const SizedBox(width: 12),
              // Away form
              Expanded(
                child: _FormCard(
                  teamName: match.awayTeam.name,
                  form: awayForm,
                  isHome: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // W/D/L summary comparison
          if (homeForm != null && awayForm != null) ...[
            Text(
              'Record Comparison',
              style: AppTextStyles.h4.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _RecordComparisonCard(
              homeForm: homeForm!,
              awayForm: awayForm!,
              homeTeamName: match.homeTeam.shortName ?? match.homeTeam.name,
              awayTeamName: match.awayTeam.shortName ?? match.awayTeam.name,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  final FootballMatch match;
  final TeamStats? homeStats;
  final TeamStats? awayStats;

  const _StatsTab({
    required this.match,
    required this.homeStats,
    required this.awayStats,
  });

  @override
  Widget build(BuildContext context) {
    if (homeStats == null || awayStats == null) {
      return Center(
        child: Text(
          'No season stats available.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
        ),
      );
    }

    final hs = homeStats!;
    final as_ = awayStats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: team names
          _StatsHeaderRow(
            homeTeamName: match.homeTeam.shortName ?? match.homeTeam.name,
            awayTeamName: match.awayTeam.shortName ?? match.awayTeam.name,
          ),
          const SizedBox(height: 12),
          // Stats rows
          _StatRow(
            label: 'Matches Played',
            homeVal: hs.played,
            awayVal: as_.played,
          ),
          _StatRow(
            label: 'Wins',
            homeVal: hs.wins,
            awayVal: as_.wins,
            higherIsBetter: true,
          ),
          _StatRow(
            label: 'Draws',
            homeVal: hs.draws,
            awayVal: as_.draws,
          ),
          _StatRow(
            label: 'Losses',
            homeVal: hs.losses,
            awayVal: as_.losses,
            higherIsBetter: false,
          ),
          _StatRow(
            label: 'Points',
            homeVal: hs.points,
            awayVal: as_.points,
            higherIsBetter: true,
          ),
          _StatRow(
            label: 'Goals For',
            homeVal: hs.goalsFor,
            awayVal: as_.goalsFor,
            higherIsBetter: true,
          ),
          _StatRow(
            label: 'Goals Against',
            homeVal: hs.goalsAgainst,
            awayVal: as_.goalsAgainst,
            higherIsBetter: false,
          ),
          _StatRow(
            label: 'Goal Difference',
            homeVal: hs.goalDifference,
            awayVal: as_.goalDifference,
            higherIsBetter: true,
          ),
          _StatRow(
            label: 'Clean Sheets',
            homeVal: hs.cleanSheets,
            awayVal: as_.cleanSheets,
            higherIsBetter: true,
          ),
          if (hs.totalYellows != null && as_.totalYellows != null)
            _StatRow(
              label: 'Yellow Cards',
              homeVal: hs.totalYellows!,
              awayVal: as_.totalYellows!,
              higherIsBetter: false,
            ),
          if (hs.totalReds != null && as_.totalReds != null)
            _StatRow(
              label: 'Red Cards',
              homeVal: hs.totalReds!,
              awayVal: as_.totalReds!,
              higherIsBetter: false,
            ),
          const SizedBox(height: 16),
          // Season label
          Center(
            child: Text(
              'Season ${hs.season}',
              style:
                  AppTextStyles.caption.copyWith(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final String teamName;
  final TeamForm? form;
  final bool isHome;

  const _FormCard({
    required this.teamName,
    required this.form,
    required this.isHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teamName,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          if (form == null)
            Text('No data',
                style: AppTextStyles.caption
                    .copyWith(color: context.textSecondary))
          else ...[
            Row(
              children: form!.form
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _FormBadge(result: r),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniStat(
                    label: 'W',
                    value: form!.wins.toString(),
                    color: AppColors.success),
                _MiniStat(
                    label: 'D',
                    value: form!.draws.toString(),
                    color: AppColors.warning),
                _MiniStat(
                    label: 'L',
                    value: form!.losses.toString(),
                    color: AppColors.error),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FormBadge extends StatelessWidget {
  final String result;
  const _FormBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (result) {
      case 'W':
        color = AppColors.success;
        break;
      case 'D':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.error;
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Center(
        child: Text(
          result,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }
}

// ─── Record Comparison Card ───────────────────────────────────────────────────

class _RecordComparisonCard extends StatelessWidget {
  final TeamForm homeForm;
  final TeamForm awayForm;
  final String homeTeamName;
  final String awayTeamName;

  const _RecordComparisonCard({
    required this.homeForm,
    required this.awayForm,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  homeTeamName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                child: Text(
                  awayTeamName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BarRow(
            label: 'Goals For',
            homeVal: homeForm.goalsFor,
            awayVal: awayForm.goalsFor,
            color: AppColors.accentGreen,
          ),
          const SizedBox(height: 10),
          _BarRow(
            label: 'Goals Against',
            homeVal: homeForm.goalsAgainst,
            awayVal: awayForm.goalsAgainst,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int homeVal;
  final int awayVal;
  final Color color;

  const _BarRow({
    required this.label,
    required this.homeVal,
    required this.awayVal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final total = homeVal + awayVal;
    final homeFrac = total == 0 ? 0.5 : homeVal / total;
    final awayFrac = total == 0 ? 0.5 : awayVal / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              homeVal.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style:
                  AppTextStyles.caption.copyWith(color: context.textSecondary),
            ),
            Text(
              awayVal.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: (homeFrac * 100).round(),
                child: Container(height: 6, color: color),
              ),
              Expanded(
                flex: (awayFrac * 100).round(),
                child:
                    Container(height: 6, color: color.withValues(alpha: 0.25)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats Header Row ─────────────────────────────────────────────────────────

class _StatsHeaderRow extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;

  const _StatsHeaderRow({
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              homeTeamName,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.accent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 100),
          Expanded(
            child: Text(
              awayTeamName,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.accent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Row ─────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final int homeVal;
  final int awayVal;

  /// If true, the higher value is highlighted green; if false, lower is better.
  final bool? higherIsBetter;

  const _StatRow({
    required this.label,
    required this.homeVal,
    required this.awayVal,
    this.higherIsBetter,
  });

  @override
  Widget build(BuildContext context) {
    Color homeColor = context.textPrimary;
    Color awayColor = context.textPrimary;

    if (higherIsBetter != null) {
      if (homeVal != awayVal) {
        final homeWins =
            higherIsBetter! ? homeVal > awayVal : homeVal < awayVal;
        homeColor = homeWins ? AppColors.success : AppColors.error;
        awayColor = homeWins ? AppColors.error : AppColors.success;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              homeVal.toString(),
              style: AppTextStyles.h4.copyWith(
                color: homeColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              awayVal.toString(),
              style: AppTextStyles.h4.copyWith(
                color: awayColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Team Logo ────────────────────────────────────────────────────────────────

class _TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;

  const _TeamLogo({this.logoUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: Image.network(
          logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(Icons.sports_soccer,
          color: context.textSecondary, size: size * 0.5),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load team stats',
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
