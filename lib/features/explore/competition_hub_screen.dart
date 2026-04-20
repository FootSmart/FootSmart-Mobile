import 'package:flutter/material.dart';
import '../../core/models/league.dart';
import '../../core/models/standing.dart';
import '../../core/services/api_service.dart';
import '../../core/services/league_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';

class CompetitionHubScreen extends StatefulWidget {
  const CompetitionHubScreen({super.key});

  @override
  State<CompetitionHubScreen> createState() => _CompetitionHubScreenState();
}

class _CompetitionHubScreenState extends State<CompetitionHubScreen>
    with SingleTickerProviderStateMixin {
  // Services
  late final LeagueService _leagueService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State
  List<League> _leagues = [];
  League? _selectedLeague;
  LeagueStandings? _currentStandings;
  bool _isLoadingLeagues = true;
  bool _isLoadingStandings = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _leagueService = LeagueService(ApiService());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadLeagues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load all available leagues from the API
  Future<void> _loadLeagues() async {
    setState(() {
      _isLoadingLeagues = true;
      _errorMessage = null;
    });

    try {
      final leagues = await _leagueService.getAllLeagues();
      setState(() {
        _leagues = leagues;
        _isLoadingLeagues = false;

        // Select the first league by default if available
        if (leagues.isNotEmpty) {
          _selectedLeague = leagues.first;
          _loadStandings(leagues.first.id);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingLeagues = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Load standings for a specific league
  Future<void> _loadStandings(String leagueId) async {
    setState(() {
      _isLoadingStandings = true;
    });

    try {
      final standings = await _leagueService.getLeagueStandings(leagueId);

      // Remove duplicates by teamId as a safety measure
      // Backend filters by MAX matchday, but this provides extra protection
      final seenTeamIds = <String>{};
      final uniqueStandings = standings.standings.where((standing) {
        if (seenTeamIds.contains(standing.teamId)) {
          return false;
        }
        seenTeamIds.add(standing.teamId);
        return true;
      }).toList();

      // Sort by position
      uniqueStandings.sort((a, b) => a.position.compareTo(b.position));

      setState(() {
        _currentStandings = LeagueStandings(
          id: standings.id,
          name: standings.name,
          country: standings.country,
          season: standings.season,
          standings: uniqueStandings,
        );
        _isLoadingStandings = false;
      });

      _animationController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _isLoadingStandings = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Handle league selection
  void _onLeagueSelected(League league) {
    if (_selectedLeague?.id == league.id) return;

    setState(() {
      _selectedLeague = league;
    });

    _loadStandings(league.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: _isLoadingLeagues
            ? _buildLoadingState()
            : _errorMessage != null && _leagues.isEmpty
                ? _buildErrorState()
                : _buildMainContent(),
      ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(context.accent),
      ),
    );
  }

  // Error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load leagues',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLeagues,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Main content
  Widget _buildMainContent() {
    return Column(
      children: [
        // Header
        _buildHeader(),

        const SizedBox(height: 16),

        // League Selector Button
        _buildLeagueSelector(),

        const SizedBox(height: 16),

        // League Stats (Compact)
        if (_selectedLeague != null) _buildLeagueStats(),

        const SizedBox(height: 16),

        // League Standings Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Icon(
                Icons.leaderboard,
                color: Color(0xFF00D9A3),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'League Standings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Standings Table Header
        _buildStandingsTableHeader(),

        // Standings List
        Expanded(
          child: _buildStandingsList(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Header widget
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.accent.withValues(alpha: 0.2),
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
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.accent,
                  context.accent.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.primaryDark,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Competition Hub',
                  style: AppTextStyles.h2.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live standings & analytics',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // League selector button widget
  Widget _buildLeagueSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: _showLeagueBottomSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.cardBg,
                context.cardBg.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.accent.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.accent,
                      context.accent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLeague?.name ?? 'Select League',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedLeague?.country != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _selectedLeague!.country!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.accent,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show league selection bottom sheet
  void _showLeagueBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: context.scaffoldBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: context.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select League',
                    style: AppTextStyles.h3.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // League list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _leagues.length,
                itemBuilder: (context, index) {
                  final league = _leagues[index];
                  final isSelected = _selectedLeague?.id == league.id;

                  return GestureDetector(
                    onTap: () {
                      _onLeagueSelected(league);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  context.accent.withValues(alpha: 0.2),
                                  context.accent.withValues(alpha: 0.1),
                                ],
                              )
                            : null,
                        color: isSelected ? null : context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.accent
                              : context.accent.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.accent
                                  : context.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sports_soccer,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : context.accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  league.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (league.country != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    league.country!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: context.accent,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // League stats widget (Compact)
  Widget _buildLeagueStats() {
    final league = _selectedLeague!;
    final standings = _currentStandings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.cardBg,
              context.cardBg.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.accent.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                  'Teams', standings?.standings.length.toString() ?? '-'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  _buildStatItem('Season', league.season?.toString() ?? 'N/A'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                  'Matchday',
                  standings?.standings.firstOrNull?.matchday?.toString() ??
                      '-'),
            ),
          ],
        ),
      ),
    );
  }

  // Stat item widget (Compact)
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.accent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Standings table header widget
  Widget _buildStandingsTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.cardBg,
              context.cardBg.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          border: Border.all(
            color: context.accent.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '#',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Team',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                'P',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 30,
              child: Text(
                'W',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 40,
              child: Text(
                'Pts',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Standings list widget
  Widget _buildStandingsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: context.accent.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: _isLoadingStandings
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(context.accent),
                  ),
                ),
              )
            : _currentStandings == null || _currentStandings!.standings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No standings available',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _currentStandings!.standings.length,
                      itemBuilder: (context, index) {
                        final standing = _currentStandings!.standings[index];
                        final position = standing.position;

                        Color positionColor = context.textSecondary;
                        if (position <= 4) {
                          positionColor = context.accent;
                        } else if (position == 5) {
                          positionColor = const Color(0xFFFFB74D);
                        } else if (position >= 18) {
                          positionColor = AppColors.error;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: context.accent.withValues(alpha: 0.1),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      positionColor.withValues(alpha: 0.2),
                                      positionColor.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: positionColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    position.toString(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: positionColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (standing.teamLogo != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    standing.teamLogo!,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: context.accent
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.shield,
                                          size: 18,
                                          color: context.accent,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Text(
                                  standing.teamName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  standing.played.toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  standing.wins.toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 44,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      context.accent.withValues(alpha: 0.2),
                                      context.accent.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  standing.points.toString(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: context.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
