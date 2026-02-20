import 'package:flutter/material.dart';
import '../../core/models/league.dart';
import '../../core/models/team.dart';
import '../../core/models/player.dart';
import '../../core/services/api_service.dart';
import '../../core/services/league_service.dart';
import '../../core/services/team_service.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum _SortStat { goals, assists, appearances, minutes, yellowCards, redCards }

enum _PositionFilter { all, goalkeeper, defender, midfielder, forward }

// ─── Helpers ──────────────────────────────────────────────────────────────────

extension on _SortStat {
  String get label {
    switch (this) {
      case _SortStat.goals:
        return 'Goals';
      case _SortStat.assists:
        return 'Assists';
      case _SortStat.appearances:
        return 'Apps';
      case _SortStat.minutes:
        return 'Mins';
      case _SortStat.yellowCards:
        return 'Yellow';
      case _SortStat.redCards:
        return 'Red';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortStat.goals:
        return Icons.sports_soccer;
      case _SortStat.assists:
        return Icons.assistant;
      case _SortStat.appearances:
        return Icons.calendar_today_outlined;
      case _SortStat.minutes:
        return Icons.timer_outlined;
      case _SortStat.yellowCards:
        return Icons.square_rounded;
      case _SortStat.redCards:
        return Icons.square_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _SortStat.goals:
        return const Color(0xFF00D9A3);
      case _SortStat.assists:
        return const Color(0xFF6C63FF);
      case _SortStat.appearances:
        return const Color(0xFF00B4D8);
      case _SortStat.minutes:
        return const Color(0xFFFFB74D);
      case _SortStat.yellowCards:
        return const Color(0xFFFFD600);
      case _SortStat.redCards:
        return const Color(0xFFFF5252);
    }
  }

  int valueFor(Player p) {
    switch (this) {
      case _SortStat.goals:
        return p.goals;
      case _SortStat.assists:
        return p.assists;
      case _SortStat.appearances:
        return p.appearances;
      case _SortStat.minutes:
        return p.minutesPlayed;
      case _SortStat.yellowCards:
        return p.yellowCards;
      case _SortStat.redCards:
        return p.redCards;
    }
  }
}

extension on _PositionFilter {
  String get label {
    switch (this) {
      case _PositionFilter.all:
        return 'All';
      case _PositionFilter.goalkeeper:
        return 'GK';
      case _PositionFilter.defender:
        return 'DEF';
      case _PositionFilter.midfielder:
        return 'MID';
      case _PositionFilter.forward:
        return 'FWD';
    }
  }

  bool matches(Player p) {
    if (this == _PositionFilter.all) return true;
    final pos = (p.position ?? '').toLowerCase();
    switch (this) {
      case _PositionFilter.goalkeeper:
        return pos.contains('goalkeeper') || pos.contains('gk');
      case _PositionFilter.defender:
        return pos.contains('defender') ||
            pos.contains('back') ||
            pos.contains('def');
      case _PositionFilter.midfielder:
        return pos.contains('midfielder') || pos.contains('mid');
      case _PositionFilter.forward:
        return pos.contains('forward') ||
            pos.contains('striker') ||
            pos.contains('winger') ||
            pos.contains('fwd') ||
            pos.contains('attacker');
      case _PositionFilter.all:
        return true;
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PlayersHubScreen extends StatefulWidget {
  const PlayersHubScreen({super.key});

  @override
  State<PlayersHubScreen> createState() => _PlayersHubScreenState();
}

class _PlayersHubScreenState extends State<PlayersHubScreen> {
  // ─── Services ──────────────────────────────────────────────────────────────
  late final LeagueService _leagueService;
  late final TeamService _teamService;

  // ─── Raw data ──────────────────────────────────────────────────────────────
  List<League> _leagues = [];
  List<Team> _teams = [];
  List<Player> _players = [];

  // ─── Filters ───────────────────────────────────────────────────────────────
  League? _selectedLeague;
  Team? _selectedTeam; // null = all teams in league
  _SortStat _sortStat = _SortStat.goals;
  _PositionFilter _positionFilter = _PositionFilter.all;
  String _searchQuery = '';
  bool _activeOnly = false;

  // ─── Loading / error state ─────────────────────────────────────────────────
  bool _loadingLeagues = true;
  bool _loadingTeams = false;
  bool _loadingPlayers = false;
  String? _error;

  // ─── Search controller ─────────────────────────────────────────────────────
  final _searchController = TextEditingController();

  // ─── Computed ──────────────────────────────────────────────────────────────
  List<Player> get _filteredPlayers {
    // Filter
    var list = _players.where((p) {
      final matchesPosition = _positionFilter.matches(p);
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.nationality ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesActive = !_activeOnly || p.isActive;
      return matchesPosition && matchesSearch && matchesActive;
    }).toList();

    // Sort descending
    list.sort((a, b) => _sortStat.valueFor(b).compareTo(_sortStat.valueFor(a)));
    return list;
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _leagueService = LeagueService(ApiService());
    _teamService = TeamService(ApiService());
    _loadLeagues();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Data loaders ──────────────────────────────────────────────────────────

  Future<void> _loadLeagues() async {
    setState(() {
      _loadingLeagues = true;
      _error = null;
    });
    try {
      final leagues = await _leagueService.getAllLeagues();
      setState(() {
        _leagues = leagues;
        _loadingLeagues = false;
      });
      if (leagues.isNotEmpty) await _selectLeague(leagues.first);
    } catch (e) {
      setState(() {
        _loadingLeagues = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _selectLeague(League league) async {
    setState(() {
      _selectedLeague = league;
      _selectedTeam = null;
      _teams = [];
      _players = [];
      _loadingTeams = true;
    });
    try {
      final teams = await _teamService.getAllTeams(leagueId: league.id);
      setState(() {
        _teams = teams;
        _loadingTeams = false;
      });
      await _loadPlayers();
    } catch (e) {
      setState(() {
        _loadingTeams = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _selectTeam(Team? team) async {
    if (_selectedTeam?.id == team?.id) return;
    setState(() {
      _selectedTeam = team;
      _players = [];
    });
    await _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    if (_selectedLeague == null) return;
    setState(() {
      _loadingPlayers = true;
      _error = null;
    });
    try {
      List<Player> players;
      if (_selectedTeam != null) {
        players = await _teamService.getTeamPlayers(_selectedTeam!.id);
      } else {
        // League-wide top scorers (sorted by goals from backend)
        players = await _teamService.getLeagueTopScorers(
          _selectedLeague!.id,
          limit: 200,
        );
      }
      setState(() {
        _players = players;
        _loadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        _loadingPlayers = false;
        _error = e.toString();
      });
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: _loadingLeagues
            ? _buildLoading()
            : _error != null && _leagues.isEmpty
                ? _buildError(_error!, _loadLeagues)
                : _buildBody(),
      ),
    );
  }

  // ─── Body sections ─────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildStatTabs(),
        _buildLeagueChips(),
        _buildTeamChips(),
        _buildPositionAndActiveRow(),
        _buildPlayersCount(),
        Expanded(child: _buildPlayerList()),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00D9A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_alt_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Players Hub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stats, rankings & analytics',
                style: TextStyle(color: Color(0xFF8E92BC), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2F4A)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search player or nationality…',
            hintStyle: TextStyle(color: Color(0xFF8E92BC), fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Color(0xFF8E92BC), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      ),
    );
  }

  // ── Stat tabs ───────────────────────────────────────────────────────────────

  Widget _buildStatTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: SizedBox(
        height: 76,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: _SortStat.values.map((stat) {
            final selected = _sortStat == stat;
            return GestureDetector(
              onTap: () => setState(() => _sortStat = stat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? stat.color.withOpacity(0.18)
                      : const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? stat.color : const Color(0xFF2A2F4A),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      stat.icon,
                      color: selected ? stat.color : const Color(0xFF8E92BC),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stat.label,
                      style: TextStyle(
                        color: selected ? stat.color : const Color(0xFF8E92BC),
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── League chips ────────────────────────────────────────────────────────────

  Widget _buildLeagueChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _leagues.length,
          itemBuilder: (_, i) {
            final l = _leagues[i];
            final sel = _selectedLeague?.id == l.id;
            return GestureDetector(
              onTap: () {
                if (!sel) _selectLeague(l);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      sel ? const Color(0xFF00D9A3) : const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        sel ? const Color(0xFF00D9A3) : const Color(0xFF2A2F4A),
                  ),
                ),
                child: Text(
                  l.name,
                  style: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF8E92BC),
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Team chips ──────────────────────────────────────────────────────────────

  Widget _buildTeamChips() {
    if (_loadingTeams) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: SizedBox(
          height: 36,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
              ),
            ),
          ),
        ),
      );
    }
    if (_teams.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // "All teams" chip
            _buildTeamChip(null),
            ...(_teams.map((t) => _buildTeamChip(t))),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamChip(Team? team) {
    final sel = _selectedTeam?.id == team?.id;
    return GestureDetector(
      onTap: () => _selectTeam(team),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFF6C63FF).withOpacity(0.25)
              : const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? const Color(0xFF6C63FF) : const Color(0xFF2A2F4A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (team == null) ...[
              const Icon(Icons.public, color: Color(0xFF8E92BC), size: 12),
              const SizedBox(width: 4),
            ],
            Text(
              team == null ? 'All Teams' : (team.shortName ?? team.name),
              style: TextStyle(
                color: sel ? const Color(0xFF6C63FF) : const Color(0xFF8E92BC),
                fontSize: 12,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Position filter + active toggle ─────────────────────────────────────────

  Widget _buildPositionAndActiveRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          // Position pills
          ...(_PositionFilter.values.map((pos) {
            final sel = _positionFilter == pos;
            return GestureDetector(
              onTap: () => setState(() => _positionFilter = pos),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF00D9A3).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        sel ? const Color(0xFF00D9A3) : const Color(0xFF2A2F4A),
                  ),
                ),
                child: Text(
                  pos.label,
                  style: TextStyle(
                    color:
                        sel ? const Color(0xFF00D9A3) : const Color(0xFF8E92BC),
                    fontSize: 11,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          })).toList(),
          const Spacer(),
          // Active-only toggle
          GestureDetector(
            onTap: () => setState(() => _activeOnly = !_activeOnly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _activeOnly
                    ? const Color(0xFFFFB74D).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _activeOnly
                      ? const Color(0xFFFFB74D)
                      : const Color(0xFF2A2F4A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 11,
                    color: _activeOnly
                        ? const Color(0xFFFFB74D)
                        : const Color(0xFF8E92BC),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: _activeOnly
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFF8E92BC),
                      fontSize: 11,
                      fontWeight:
                          _activeOnly ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Player count bar ────────────────────────────────────────────────────────

  Widget _buildPlayersCount() {
    final count = _filteredPlayers.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Icon(
            _sortStat.icon,
            color: _sortStat.color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Sorted by ${_sortStat.label}',
            style: TextStyle(
              color: _sortStat.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_loadingPlayers)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
              ),
            )
          else
            Text(
              '$count players',
              style: const TextStyle(
                color: Color(0xFF8E92BC),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  // ── Player list ─────────────────────────────────────────────────────────────

  Widget _buildPlayerList() {
    if (_loadingPlayers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
        ),
      );
    }

    final players = _filteredPlayers;

    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 56, color: const Color(0xFF2A2F4A)),
            const SizedBox(height: 16),
            const Text(
              'No players found',
              style: TextStyle(color: Color(0xFF8E92BC), fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting filters or selecting a different team',
              style: TextStyle(color: Color(0xFF4A4F6A), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: players.length,
      itemBuilder: (context, index) =>
          _buildPlayerCard(players[index], index + 1),
    );
  }

  // ── Player card ─────────────────────────────────────────────────────────────

  Widget _buildPlayerCard(Player player, int rank) {
    final statValue = _sortStat.valueFor(player);
    final statColor = _sortStat.color;

    // Rank badge color
    Color rankColor = const Color(0xFF4A4F6A);
    if (rank == 1) rankColor = const Color(0xFFFFD700);
    if (rank == 2) rankColor = const Color(0xFFC0C0C0);
    if (rank == 3) rankColor = const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              rank <= 3 ? rankColor.withOpacity(0.3) : const Color(0xFF2A2F4A),
          width: rank <= 3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // ─── Rank badge ──────────────────────────────────────────────────
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      rank == 1
                          ? Icons.workspace_premium
                          : Icons.emoji_events_outlined,
                      color: rankColor,
                      size: 16,
                    )
                  : Text(
                      rank.toString(),
                      style: TextStyle(
                        color: rankColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // ─── Avatar ──────────────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statColor.withOpacity(0.3),
                  statColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _initials(player.name),
                style: TextStyle(
                  color: statColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ─── Player info ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (player.position != null) ...[
                      _positionBadge(player.position!),
                      const SizedBox(width: 6),
                    ],
                    if (player.nationality != null)
                      Text(
                        player.nationality!,
                        style: const TextStyle(
                          color: Color(0xFF8E92BC),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Mini stat pills row
                _buildMiniStatPills(player),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ─── Primary stat ─────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statValue.toString(),
                  style: TextStyle(
                    color: statColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _sortStat.label,
                style: const TextStyle(color: Color(0xFF8E92BC), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Mini stat pills ──────────────────────────────────────────────────────

  Widget _buildMiniStatPills(Player p) {
    final pills = <_MiniStat>[
      if (_sortStat != _SortStat.goals)
        _MiniStat(
            Icons.sports_soccer, p.goals.toString(), const Color(0xFF00D9A3)),
      if (_sortStat != _SortStat.assists)
        _MiniStat(
            Icons.assistant, p.assists.toString(), const Color(0xFF6C63FF)),
      if (_sortStat != _SortStat.appearances)
        _MiniStat(Icons.calendar_today_outlined, p.appearances.toString(),
            const Color(0xFF00B4D8)),
    ];

    return Row(
      children: pills
          .take(3)
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(s.icon, size: 10, color: s.color),
                  const SizedBox(width: 2),
                  Text(
                    s.value,
                    style: TextStyle(color: s.color, fontSize: 10),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ─── Position badge ──────────────────────────────────────────────────────

  Widget _positionBadge(String position) {
    final abbr = _positionAbbr(position);
    final color = _positionColor(position);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        abbr,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Utils ───────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _positionAbbr(String position) {
    final p = position.toLowerCase();
    if (p.contains('goalkeeper') || p.contains('gk')) return 'GK';
    if (p.contains('defender') || p.contains('back') || p.contains('def')) {
      return 'DEF';
    }
    if (p.contains('midfielder') || p.contains('mid')) return 'MID';
    if (p.contains('forward') ||
        p.contains('striker') ||
        p.contains('winger') ||
        p.contains('fwd') ||
        p.contains('attacker')) return 'FWD';
    return position.substring(0, position.length.clamp(0, 3)).toUpperCase();
  }

  Color _positionColor(String position) {
    final p = position.toLowerCase();
    if (p.contains('goalkeeper') || p.contains('gk')) {
      return const Color(0xFFFFB74D);
    }
    if (p.contains('defender') || p.contains('back') || p.contains('def')) {
      return const Color(0xFF00B4D8);
    }
    if (p.contains('midfielder') || p.contains('mid')) {
      return const Color(0xFF6C63FF);
    }
    return const Color(0xFF00D9A3);
  }

  // ─── Shared states ────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF8E92BC), size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF8E92BC), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9A3),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper data class ────────────────────────────────────────────────────────

class _MiniStat {
  final IconData icon;
  final String value;
  final Color color;
  const _MiniStat(this.icon, this.value, this.color);
}
