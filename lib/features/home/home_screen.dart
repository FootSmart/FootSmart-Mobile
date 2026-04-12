import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';
import '../../core/models/league.dart';
import '../../core/models/match.dart';
import '../../core/services/api_service.dart';
import '../../core/services/league_service.dart';
import '../../core/services/match_service.dart';
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
  List<FootballMatch> _upcomingMatches = [];

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

  /// Filtre local sur la liste déjà chargée (équipes, ligue, lieu, statut…).
  List<FootballMatch> get _filteredMatches {
    final q = _matchSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return _upcomingMatches;

    bool contains(String? s) =>
        s != null && s.toLowerCase().contains(q);

    return _upcomingMatches.where((m) {
      final dateStr = m.matchDate != null
          ? '${m.matchDate!.day}/${m.matchDate!.month}/${m.matchDate!.year}'
          : '';
      return contains(m.leagueName) ||
          contains(m.leagueCountry) ||
          contains(m.homeTeam.name) ||
          contains(m.homeTeam.shortName) ||
          contains(m.awayTeam.name) ||
          contains(m.awayTeam.shortName) ||
          contains(m.venue) ||
          contains(m.status) ||
          dateStr.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildMatchSearchField(BuildContext context) {
    final hasText = _matchSearchController.text.isNotEmpty;

    return TextField(
      controller: _matchSearchController,
      focusNode: _matchSearchFocus,
      onChanged: (_) => setState(() {}),
      style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
      cursorColor: context.accent,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher un match…',
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
                  setState(() {});
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
    });
    try {
      final response = await _matchService.getUpcomingMatches(
        limit: 100,
        leagueId: leagueId,
        nextGameweek: true,
      );
      if (mounted) {
        setState(() {
          _upcomingMatches = response.matches;
          _matchesLoading = false;
        });
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
    setState(() => _selectedLeagueId = leagueId);
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: context.iconColor,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: context.accentOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.cardBg,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Upcoming Matches Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Matches',
                          style: AppTextStyles.h3.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedLeagueId == null
                              ? 'Next gameweek across leagues'
                              : 'Next gameweek for selected league',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textSecondary,
                          ),
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
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.accent,
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _leagues.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                          final leagueId = isAll ? null : _leagues[index - 1].id;
                          final label = isAll ? 'All Leagues' : _leagues[index - 1].name;
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
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
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
                else if (_upcomingMatches.isEmpty)
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredMatches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final match = _filteredMatches[index];
                      return _UpcomingMatchCard(
                        match: match,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.matchDetail,
                          arguments: match,
                        ),
                      );
                    },
                  ),

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
            Navigator.pushNamed(context, AppRoutes.explore);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.betting);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.wallet);
          } else if (index == 4) {
            Navigator.pushNamed(context, AppRoutes.profile);
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // League and Risk
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.leagueName ?? 'Unknown League',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  match.matchDate != null
                      ? '${match.matchDate!.day}/${match.matchDate!.month}/${match.matchDate!.year}'
                      : (match.matchTime ?? 'TBD'),
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Teams with logos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: [
                      _TeamLogo(logoUrl: match.homeTeam.logo, size: 56),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam.shortName ?? match.homeTeam.name,
                        style: AppTextStyles.h4.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // VS Icon
                Container(
                  padding: const EdgeInsets.all(8),
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
                // Away team
                Expanded(
                  child: Column(
                    children: [
                      _TeamLogo(logoUrl: match.awayTeam.logo, size: 56),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam.shortName ?? match.awayTeam.name,
                        style: AppTextStyles.h4.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Match status from backend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(width: 6),
                      Text(
                        'Status',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        match.status.toUpperCase(),
                        style: AppTextStyles.h4.copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
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
