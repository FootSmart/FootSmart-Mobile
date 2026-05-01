import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/models/league.dart';
import 'package:footsmart_pro/core/models/team.dart';
import 'package:footsmart_pro/core/services/admin_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/league_service.dart';
import 'package:footsmart_pro/core/services/team_service.dart';
import 'package:footsmart_pro/features/admin/admin_refresh_bus.dart';

class AdminTestLabScreen extends StatefulWidget {
  const AdminTestLabScreen({super.key});

  @override
  State<AdminTestLabScreen> createState() => _AdminTestLabScreenState();
}

class _AdminTestLabScreenState extends State<AdminTestLabScreen> {
  final AdminService _adminService = AdminService(ApiService());
  final LeagueService _leagueService = LeagueService(ApiService());
  final TeamService _teamService = TeamService(ApiService());

  final TextEditingController _minutesController = TextEditingController(text: '15');
  final TextEditingController _homeOddsController = TextEditingController(text: '2.1');
  final TextEditingController _drawOddsController = TextEditingController(text: '3.0');
  final TextEditingController _awayOddsController = TextEditingController(text: '3.8');

  bool _loading = true;
  bool _actionLoading = false;
  List<League> _leagues = [];
  List<Team> _teams = [];
  League? _league;
  Team? _home;
  Team? _away;
  Map<String, dynamic>? _lastCreated;
  Map<String, dynamic>? _lastSettlement;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final leagues = await _leagueService.getAllLeagues();
      if (!mounted) return;
      setState(() {
        _leagues = leagues;
        _league = leagues.isNotEmpty ? leagues.first : null;
      });
      await _loadTeams();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load test lab data: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadTeams() async {
    if (_league == null) return;
    final teams = await _teamService.getAllTeams(leagueId: _league!.id);
    if (!mounted) return;
    setState(() {
      _teams = teams;
      _home = teams.isNotEmpty ? teams.first : null;
      _away = teams.length > 1 ? teams[1] : null;
    });
  }

  Future<void> _generate() async {
    if (_league == null || _home == null || _away == null) return;
    if (_home!.id == _away!.id) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose different teams')));
      return;
    }
    setState(() => _actionLoading = true);
    try {
      final result = await _adminService.generateTestMatch(
        leagueId: _league!.id,
        homeTeamId: _home!.id,
        awayTeamId: _away!.id,
        minutesFromNow: int.tryParse(_minutesController.text) ?? 15,
        betCloseMinutesBeforeKickoff: 5,
        homeOdds: double.tryParse(_homeOddsController.text) ?? 2.1,
        drawOdds: double.tryParse(_drawOddsController.text) ?? 3.0,
        awayOdds: double.tryParse(_awayOddsController.text) ?? 3.8,
      );
      if (!mounted) return;
      setState(() => _lastCreated = result);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Test match generated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Generation failed: $e')));
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _finish(int homeGoals, int awayGoals) async {
    final matchId = _lastCreated?['match']?['id']?.toString();
    if (matchId == null || matchId.isEmpty) return;
    setState(() => _actionLoading = true);
    try {
      final result = await _adminService.finishMatch(
        matchId,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
      );
      if (!mounted) return;
      final settlement = Map<String, dynamic>.from(
        (result['settlement'] as Map?) ?? const {},
      );
      setState(() => _lastSettlement = settlement);
      AdminRefreshBus.notifyUpdated();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Match finished and bets settled')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Finish failed: $e')));
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00C896)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _metricTile(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1625),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9DA8C3), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF00C896),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(title: const Text('Admin Test Lab')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionCard(
                  icon: Icons.science_outlined,
                  title: 'Generate Match',
                  child: Column(
                    children: [
                      DropdownButtonFormField<League>(
                        value: _league,
                        decoration: const InputDecoration(labelText: 'League'),
                        items: _leagues
                            .map((l) => DropdownMenuItem(value: l, child: Text(l.name)))
                            .toList(),
                        onChanged: (value) async {
                          setState(() => _league = value);
                          await _loadTeams();
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Team>(
                        value: _home,
                        decoration: const InputDecoration(labelText: 'Home team'),
                        items: _teams
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                            .toList(),
                        onChanged: (value) => setState(() => _home = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Team>(
                        value: _away,
                        decoration: const InputDecoration(labelText: 'Away team'),
                        items: _teams
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                            .toList(),
                        onChanged: (value) => setState(() => _away = value),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Minutes from now'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _homeOddsController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Home odds'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _drawOddsController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Draw odds'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _awayOddsController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Away odds'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _actionLoading ? null : _generate,
                          icon: _actionLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_fix_high),
                          label: const Text('Generate Test Match'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_lastCreated != null) ...[
                  _sectionCard(
                    icon: Icons.sports_soccer,
                    title: 'Generated Match',
                    child: Builder(builder: (context) {
                      final match = _lastCreated?['match'] as Map?;
                      final odds = _lastCreated?['odds'] as Map?;
                      final homeOdds = odds?['home_odds'] ?? odds?['home_win_odds'] ?? '-';
                      final drawOdds = odds?['draw_odds'] ?? '-';
                      final awayOdds = odds?['away_odds'] ?? odds?['away_win_odds'] ?? '-';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Match ID: ${match?['id'] ?? '-'}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kickoff: ${match?['match_date'] ?? '-'} ${match?['match_time'] ?? '-'}',
                            style:
                                const TextStyle(color: Color(0xFFBBC7E6), fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bet close time: ${match?['bet_closes_at'] ?? '-'}',
                            style:
                                const TextStyle(color: Color(0xFFBBC7E6), fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _metricTile('Home odds', homeOdds)),
                              const SizedBox(width: 8),
                              Expanded(child: _metricTile('Draw odds', drawOdds)),
                              const SizedBox(width: 8),
                              Expanded(child: _metricTile('Away odds', awayOdds)),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                  _sectionCard(
                    icon: Icons.flag,
                    title: 'Finish Match',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _actionLoading ? null : () => _finish(2, 1),
                          icon: const Icon(Icons.emoji_events_outlined),
                          label: const Text('Finish Home Win'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _actionLoading ? null : () => _finish(1, 1),
                          icon: const Icon(Icons.balance_outlined),
                          label: const Text('Finish Draw'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _actionLoading ? null : () => _finish(1, 2),
                          icon: const Icon(Icons.flight_takeoff_outlined),
                          label: const Text('Finish Away Win'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_lastSettlement != null)
                  _sectionCard(
                    icon: Icons.summarize,
                    title: 'Settlement Summary',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _metricTile(
                                'Settled bets',
                                _lastSettlement?['settled'] ?? 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _metricTile(
                                'Won bets',
                                _lastSettlement?['won'] ?? 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _metricTile(
                                'Lost bets',
                                _lastSettlement?['lost'] ?? 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _metricTile(
                          'Total points paid',
                          _lastSettlement?['totalPointsPaid'] ?? 0,
                        ),
                      ],
                    ),
                  ),
                _sectionCard(
                  icon: Icons.checklist_rtl,
                  title: 'Manual Test Flow',
                  child: const Text(
                    '1. Generate test match\n'
                    '2. Open app as normal user\n'
                    '3. Place bet before close time\n'
                    '4. Return to Admin Test Lab\n'
                    '5. Finish Home/Draw/Away\n'
                    '6. Verify wallet and bet history refresh',
                    style: TextStyle(color: Color(0xFFBBC7E6)),
                  ),
                ),
              ],
            ),
    );
  }
}
