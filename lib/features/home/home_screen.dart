import 'dart:async';
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

  // Top 5 European leagues
  static const _topLeagueNames = [
    'Bundesliga',
    'Premier League',
    'Ligue 1',
    'LaLiga',
    'Serie A',
  ];

  List<League> _leagues = [];
  List<League> _topLeagues = [];
  String? _selectedLeagueId; // null = All Leagues
  List<FootballMatch> _upcomingMatches = [];

  bool _leaguesLoading = true;
  bool _matchesLoading = true;
  String? _matchesError;
  final Completer<void> _leaguesCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _leagueService = LeagueService(api);
    _matchService = MatchService(api);
    _loadLeagues();
    _loadFeaturedMatches();
  }

  Future<void> _loadLeagues() async {
    try {
      final leagues = await _leagueService.getAllLeagues();
      if (mounted) {
        setState(() {
          _leagues = leagues;
          // Filter top 5 leagues by name
          _topLeagues = leagues
              .where((league) => _topLeagueNames.any((topName) =>
                  league.name.toLowerCase().contains(topName.toLowerCase())))
              .toList();
          _leaguesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _leaguesLoading = false);
    } finally {
      if (!_leaguesCompleter.isCompleted) _leaguesCompleter.complete();
    }
  }

  /// Load featured matches from top 5 leagues (1 match per league)
  Future<void> _loadFeaturedMatches() async {
    setState(() {
      _matchesLoading = true;
      _matchesError = null;
    });

    try {
      final List<FootballMatch> featuredMatches = [];

      // Wait for leagues to load using Completer (no polling)
      await _leaguesCompleter.future;

      // Fetch 1 match from each top league
      for (final league in _topLeagues) {
        try {
          final response = await _matchService.getUpcomingMatches(
            limit: 1,
            leagueId: league.id,
          );
          if (response.matches.isNotEmpty) {
            featuredMatches.add(response.matches.first);
          }
        } catch (e) {
          // Continue if one league fails
          print('Failed to load matches for ${league.name}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _upcomingMatches = featuredMatches;
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

  Future<void> _loadUpcomingMatches({String? leagueId}) async {
    setState(() {
      _matchesLoading = true;
      _matchesError = null;
    });
    try {
      final response = await _matchService.getUpcomingMatches(
        limit: 10,
        leagueId: leagueId,
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
    // If "All Leagues" is selected, show featured matches from top 5 leagues
    if (leagueId == null) {
      _loadFeaturedMatches();
    } else {
      _loadUpcomingMatches(leagueId: leagueId);
    }
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
                          'Welcome back,',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'John Doe',
                          style: AppTextStyles.h2.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
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

                // Risk Meter Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: context.accent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Risk Meter',
                                style: AppTextStyles.h4.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Moderate',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.borderColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.borderColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You've placed 5 bets this week (Limit: 10)",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Featured Matches Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Featured Matches',
                          style: AppTextStyles.h3.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Top 5 European Leagues',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Reset to show featured matches
                        setState(() => _selectedLeagueId = null);
                        _loadFeaturedMatches();
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

                // League filter chips (Top 5 leagues only)
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
                          itemCount: _topLeagues.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final leagueId =
                                isAll ? null : _topLeagues[index - 1].id;
                            final label = isAll
                                ? 'All Top 5'
                                : _topLeagues[index - 1].name;
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
                            if (_selectedLeagueId == null) {
                              _loadFeaturedMatches();
                            } else {
                              _loadUpcomingMatches(leagueId: _selectedLeagueId);
                            }
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
                                ? 'No upcoming matches in top leagues'
                                : 'No matches found for this league',
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
                    itemCount: _upcomingMatches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final match = _upcomingMatches[index];
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

                const SizedBox(height: 24),

                // Trending Bets Section
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: context.accentOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trending Bets',
                      style: AppTextStyles.h3.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Trending Bet 1
                _TrendingBetCard(
                  betTitle: 'Over 2.5 Goals',
                  match: 'Man City vs Liverpool',
                  percentage: '78%',
                  backingText: 'backing this',
                ),

                const SizedBox(height: 12),

                // Trending Bet 2
                _TrendingBetCard(
                  betTitle: 'Barcelona Win',
                  match: 'Barcelona vs Real Madrid',
                  percentage: '64%',
                  backingText: 'backing this',
                ),

                const SizedBox(height: 12),

                // Trending Bet 3
                _TrendingBetCard(
                  betTitle: 'BTTS Yes',
                  match: 'Bayern vs Dortmund',
                  percentage: '71%',
                  backingText: 'backing this',
                ),

                const SizedBox(height: 24),

                // Top Predictors Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Predictors',
                      style: AppTextStyles.h3.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: context.accent,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Predictor 1
                _PredictorCard(
                  rank: '1',
                  rankColor: const Color(0xFFFFD700),
                  username: 'BetMaster_99',
                  wins: '142 wins',
                  accuracy: '94%',
                ),

                const SizedBox(height: 12),

                // Predictor 2
                _PredictorCard(
                  rank: '2',
                  rankColor: const Color(0xFF808080),
                  username: 'FootballPro',
                  wins: '138 wins',
                  accuracy: '91%',
                ),

                const SizedBox(height: 12),

                // Predictor 3
                _PredictorCard(
                  rank: '3',
                  rankColor: const Color(0xFFCD7F32),
                  username: 'StatKing',
                  wins: '135 wins',
                  accuracy: '89%',
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

  Color get _riskColor {
    // Simple logic: you can enhance this based on odds or predictions
    final random = match.id.hashCode % 3;
    switch (random) {
      case 0:
        return AppColors.success; // Low risk
      case 1:
        return AppColors.warning; // Medium risk
      default:
        return AppColors.error; // High risk
    }
  }

  String get _riskLabel {
    final random = match.id.hashCode % 3;
    switch (random) {
      case 0:
        return 'Low Risk';
      case 1:
        return 'Medium Risk';
      default:
        return 'High Risk';
    }
  }

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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.sports_soccer,
                          color: context.accent,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
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
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _riskLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: _riskColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
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

            // Odds
            Row(
              children: [
                Expanded(
                  child: _OddsButton(
                    label: 'Home',
                    odds: '2.1',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OddsButton(
                    label: 'Draw',
                    odds: '3.4',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OddsButton(
                    label: 'Away',
                    odds: '3.8',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // AI Confidence
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
                        'AI Confidence',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '87%',
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

class _OddsButton extends StatelessWidget {
  final String label;
  final String odds;

  const _OddsButton({
    required this.label,
    required this.odds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            odds,
            style: AppTextStyles.h4.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLogo extends StatelessWidget {
  final String? logoUrl;
  const _SmallLogo({this.logoUrl});

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _icon(context),
        ),
      );
    }
    return _icon(context);
  }

  Widget _icon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.sports_soccer, color: context.textSecondary, size: 20),
    );
  }
}

class _TrendingBetCard extends StatelessWidget {
  final String betTitle;
  final String match;
  final String percentage;
  final String backingText;

  const _TrendingBetCard({
    required this.betTitle,
    required this.match,
    required this.percentage,
    required this.backingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  betTitle,
                  style: AppTextStyles.h4.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: AppTextStyles.h3.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                backingText,
                style: AppTextStyles.caption.copyWith(
                  color: context.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PredictorCard extends StatelessWidget {
  final String rank;
  final Color rankColor;
  final String username;
  final String wins;
  final String accuracy;

  const _PredictorCard({
    required this.rank,
    required this.rankColor,
    required this.username,
    required this.wins,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: AppTextStyles.h4.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wins,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                accuracy,
                style: AppTextStyles.h3.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'accuracy',
                style: AppTextStyles.caption.copyWith(
                  color: context.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
