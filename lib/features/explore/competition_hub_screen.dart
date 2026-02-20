import 'package:flutter/material.dart';
import '../../core/models/league.dart';
import '../../core/models/standing.dart';
import '../../core/services/api_service.dart';
import '../../core/services/league_service.dart';

class CompetitionHubScreen extends StatefulWidget {
  const CompetitionHubScreen({super.key});

  @override
  State<CompetitionHubScreen> createState() => _CompetitionHubScreenState();
}

class _CompetitionHubScreenState extends State<CompetitionHubScreen> {
  // Services
  late final LeagueService _leagueService;

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
    _loadLeagues();
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
      setState(() {
        _currentStandings = standings;
        _isLoadingStandings = false;
      });
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
      backgroundColor: const Color(0xFF0A0E27),
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
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
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
              color: Color(0xFF8E92BC),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load leagues',
              style: const TextStyle(
                color: Color(0xFF8E92BC),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLeagues,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9A3),
                foregroundColor: Colors.white,
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

        // League Selector
        _buildLeagueSelector(),

        const SizedBox(height: 20),

        // League Stats
        if (_selectedLeague != null) _buildLeagueStats(),

        const SizedBox(height: 20),

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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9A3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Competition Hub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'League standings & analytics',
                style: TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // League selector widget
  Widget _buildLeagueSelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: _leagues.length,
        itemBuilder: (context, index) {
          final league = _leagues[index];
          final isSelected = _selectedLeague?.id == league.id;

          return GestureDetector(
            onTap: () => _onLeagueSelected(league),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00D9A3)
                    : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00D9A3)
                      : const Color(0xFF2A2F4A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    league.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // League stats widget
  Widget _buildLeagueStats() {
    final league = _selectedLeague!;
    final standings = _currentStandings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2F4A),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              league.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              league.country ?? 'Unknown',
              style: const TextStyle(
                color: Color(0xFF8E92BC),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                    'Teams', standings?.standings.length.toString() ?? '-'),
                const SizedBox(width: 24),
                _buildStatItem('Matches', '-'),
                const SizedBox(width: 24),
                _buildStatItem('Season', league.season?.toString() ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Stat item widget
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E92BC),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F3A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                'Pos',
                style: TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Team',
                style: TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                'P',
                style: TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 30,
              child: Text(
                'W',
                style: TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 40,
              child: Text(
                'Pts',
                style: TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F3A),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: _isLoadingStandings
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
                  ),
                ),
              )
            : _currentStandings == null || _currentStandings!.standings.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No standings available',
                        style: TextStyle(
                          color: Color(0xFF8E92BC),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _currentStandings!.standings.length,
                    itemBuilder: (context, index) {
                      final standing = _currentStandings!.standings[index];
                      final position = standing.position;

                      Color positionColor = const Color(0xFF8E92BC);
                      if (position <= 4) {
                        positionColor = const Color(0xFF00D9A3);
                      } else if (position == 5) {
                        positionColor = const Color(0xFFFFB74D);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFF2A2F4A).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: positionColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  position.toString(),
                                  style: TextStyle(
                                    color: positionColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                standing.teamName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                standing.played.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF8E92BC),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 30,
                              child: Text(
                                standing.wins.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF8E92BC),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 40,
                              child: Text(
                                standing.points.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
    );
  }
}
