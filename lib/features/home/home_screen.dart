import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/models/league.dart';
import '../../core/models/match.dart';
import '../../core/services/api_service.dart';
import '../../core/services/league_service.dart';
import '../../core/services/match_service.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_skeleton.dart';
import '../../shared/widgets/app_text.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final LeagueService _leagueService;
  late final MatchService _matchService;

  List<League> _leagues = [];
  String? _selectedLeagueId; // null = All Leagues
  List<FootballMatch> _allMatches = [];
  List<FootballMatch> _filteredMatches = [];

  bool _leaguesLoading = true;
  bool _matchesLoading = true;
  String? _matchesError;

  final TextEditingController _matchSearchController = TextEditingController();
  final FocusNode _matchSearchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _leagueService = LeagueService(api);
    _matchService = MatchService(api);
    _loadInitialData();
  }

  @override
  void dispose() {
    _matchSearchController.dispose();
    _matchSearchFocus.dispose();
    super.dispose();
  }

  List<FootballMatch> _dedupeMatches(List<FootballMatch> rows) {
    final byId = <String, FootballMatch>{};
    for (final m in rows) {
      byId.putIfAbsent(m.id, () => m);
    }
    return byId.values.toList();
  }

  void _applySearch() {
    final q = _matchSearchController.text.trim().toLowerCase();

    bool contains(String? s) => s != null && s.toLowerCase().contains(q);

    final leagueSafe = _selectedLeagueId == null
        ? _allMatches
        : _allMatches.where((m) => m.leagueId == _selectedLeagueId).toList();

    if (q.isEmpty) {
      setState(() {
        _filteredMatches = _dedupeMatches(leagueSafe);
      });
      return;
    }

    final filtered = leagueSafe.where((m) {
      return contains(m.homeTeam.name) ||
          contains(m.homeTeam.shortName) ||
          contains(m.awayTeam.name) ||
          contains(m.awayTeam.shortName) ||
          contains(m.leagueName) ||
          contains(m.leagueCountry);
    }).toList();

    setState(() {
      _filteredMatches = _dedupeMatches(filtered);
    });
  }

  Widget _buildMatchSearchField(BuildContext context) {
    final hasText = _matchSearchController.text.isNotEmpty;

    return TextField(
      controller: _matchSearchController,
      focusNode: _matchSearchFocus,
      onChanged: (_) => _applySearch(),
      style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
      cursorColor: context.accent,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search teams or leagues',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: context.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: context.accent,
          size: 22,
        ),
        suffixIcon: hasText
            ? IconButton(
                tooltip: 'Effacer',
                onPressed: () {
                  _matchSearchController.clear();
                  _applySearch();
                  _matchSearchFocus.unfocus();
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: context.textSecondary,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: context.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.accent, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    await _loadLeagues();
    await _loadUpcomingMatches();
  }

  Future<void> _loadLeagues() async {
    try {
      final leagues = await _leagueService.getAllLeagues();
      if (mounted) {
        setState(() {
          _leagues = leagues;
          _leaguesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _leaguesLoading = false);
    }
  }

  Future<void> _loadUpcomingMatches({String? leagueId}) async {
    setState(() {
      _matchesLoading = true;
      _matchesError = null;
      _allMatches = [];
      _filteredMatches = [];
    });
    try {
      final response = await _matchService.getUpcomingMatches(
        limit: 100,
        leagueId: leagueId,
        nextGameweek: true,
      );
      if (mounted) {
        final deduped = _dedupeMatches(response.matches);

        setState(() {
          _allMatches = deduped;
          _filteredMatches = deduped;
          _matchesLoading = false;
        });

        _applySearch();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _matchesError = e.toString();
          _matchesLoading = false;
        });
      }
    }
  }

  void _selectLeague(String? leagueId) {
    if (_selectedLeagueId == leagueId) return;
    setState(() {
      _selectedLeagueId = leagueId;
      _allMatches = [];
      _filteredMatches = [];
    });
    _loadUpcomingMatches(leagueId: leagueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHero(
                  selectedLeagueLabel: _selectedLeagueId == null
                      ? 'All leagues'
                      : 'Focused league',
                  onNotificationsTap: () =>
                      AppRoutes.push(context, AppRoutes.notifications),
                ),

                const SizedBox(height: 24),

                // Upcoming Matches Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'Upcoming Matches',
                          variant: AppTextVariant.h2,
                          fontWeight: FontWeight.w700,
                        ),
                        AppText(
                          _selectedLeagueId == null
                              ? 'Next gameweek across leagues'
                              : 'Next gameweek for selected league',
                          variant: AppTextVariant.caption,
                          tone: AppTextTone.secondary,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        _loadUpcomingMatches(leagueId: _selectedLeagueId);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            color: context.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: context.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildMatchSearchField(context),

                const SizedBox(height: 12),

                // League filter chips
                SizedBox(
                  height: 36,
                  child: _leaguesLoading
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (_, __) => const AppSkeleton(
                            width: 92,
                            height: 32,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppRadius.full),
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _leagues.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final leagueId =
                                isAll ? null : _leagues[index - 1].id;
                            final label =
                                isAll ? 'All Leagues' : _leagues[index - 1].name;
                            final isSelected = _selectedLeagueId == leagueId;

                            return GestureDetector(
                              onTap: () => _selectLeague(leagueId),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.accent
                                      : context.cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? context.accent
                                        : context.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.primaryDark
                                        : context.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Upcoming matches list
                if (_matchesLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Column(
                      children: [
                        AppSkeleton.card(),
                        SizedBox(height: AppSpacing.sm),
                        AppSkeleton.card(),
                      ],
                    ),
                  )
                else if (_matchesError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            color: context.textSecondary, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Could not load matches',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            _loadUpcomingMatches(leagueId: _selectedLeagueId);
                          },
                          child: Text('Retry',
                              style: AppTextStyles.buttonMedium
                                  .copyWith(color: context.accent)),
                        ),
                      ],
                    ),
                  )
                else if (_allMatches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            color: context.textSecondary,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedLeagueId == null
                                ? 'No upcoming matches available'
                                : 'No matches found for this league',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: context.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_filteredMatches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: context.textSecondary,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun match ne correspond à votre recherche',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: context.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Builder(builder: (_) {
                    final renderSafe = _dedupeMatches(_filteredMatches)
                        .where((m) =>
                            _selectedLeagueId == null ||
                            m.leagueId == _selectedLeagueId)
                        .toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: renderSafe.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final match = renderSafe[index];
                        return _UpcomingMatchCard(
                          match: match,
                          onTap: () => AppRoutes.push(
                            context,
                            AppRoutes.matchDetail,
                            extra: match,
                          ),
                        );
                      },
                    );
                  }),

                const SizedBox(height: 100), // Bottom nav spacing
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            AppRoutes.push(context, AppRoutes.explore);
          } else if (index == 2) {
            AppRoutes.push(context, AppRoutes.betting);
          } else if (index == 3) {
            AppRoutes.push(context, AppRoutes.wallet);
          } else if (index == 4) {
            AppRoutes.push(context, AppRoutes.profile);
          }
        },
      ),
    );
  }
}

class _UpcomingMatchCard extends StatelessWidget {
  final FootballMatch match;
  final VoidCallback onTap;

  const _UpcomingMatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  match.leagueName ?? 'Unknown League',
                  variant: AppTextVariant.caption,
                  tone: AppTextTone.secondary,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: match.matchDate != null
                    ? '${match.matchDate!.day}/${match.matchDate!.month}/${match.matchDate!.year}'
                    : (match.matchTime ?? 'TBD'),
                variant: AppBadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _TeamLogo(logoUrl: match.homeTeam.logo, size: 56),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      match.homeTeam.shortName ?? match.homeTeam.name,
                      variant: AppTextVariant.h3,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  color: context.accent,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _TeamLogo(logoUrl: match.awayTeam.logo, size: 56),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      match.awayTeam.shortName ?? match.awayTeam.name,
                      variant: AppTextVariant.h3,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.surfaceBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: context.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: context.accent,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const AppText(
                      'Status',
                      variant: AppTextVariant.caption,
                      tone: AppTextTone.secondary,
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppBadge(
                      label: match.status.toUpperCase(),
                      variant: AppBadgeVariant.info,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right,
                      color: context.accent,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final String selectedLeagueLabel;
  final VoidCallback onNotificationsTap;

  const _HomeHero({
    required this.selectedLeagueLabel,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.accent.withValues(alpha: 0.2),
            context.surfaceBg,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Welcome Back',
                  variant: AppTextVariant.h2,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  'Now tracking: $selectedLeagueLabel',
                  variant: AppTextVariant.body,
                  tone: AppTextTone.secondary,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationsTap,
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: context.textPrimary,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: context.accentOrange,
                      shape: BoxShape.circle,
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
}

class _TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;

  const _TeamLogo({this.logoUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.sports_soccer,
          color: context.textSecondary, size: size * 0.5),
    );
  }
}
