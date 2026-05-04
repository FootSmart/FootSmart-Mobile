import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/services/admin_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/features/admin/admin_refresh_bus.dart';

class AdminMatchesScreen extends StatefulWidget {
  const AdminMatchesScreen({super.key});

  @override
  State<AdminMatchesScreen> createState() => _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends State<AdminMatchesScreen> {
  final AdminService _adminService = AdminService(ApiService());
  final TextEditingController _searchController = TextEditingController();
  late final VoidCallback _refreshListener;
  String _status = '';
  bool _isLoading = true;
  List<dynamic> _matches = [];

  @override
  void initState() {
    super.initState();
    _refreshListener = () {
      _load();
    };
    AdminRefreshBus.tick.addListener(_refreshListener);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    AdminRefreshBus.tick.removeListener(_refreshListener);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _adminService.getAdminMatches(
        status: _status.isEmpty ? null : _status,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() => _matches = res['matches'] as List<dynamic>? ?? []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load matches: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _finish(Map<String, dynamic> match, int hg, int ag) async {
    try {
      final res = await _adminService.finishMatch(
        match['id'].toString(),
        homeGoals: hg,
        awayGoals: ag,
      );
      if (!mounted) return;
      final settlement = Map<String, dynamic>.from(
        (res['settlement'] as Map?) ?? const {},
      );
      AdminRefreshBus.notifyUpdated();
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Match finished and bets settled • settled: ${settlement['settled'] ?? 0}, won: ${settlement['won'] ?? 0}, lost: ${settlement['lost'] ?? 0}',
          ),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Finish failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text('Admin Matches'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status.isEmpty ? null : _status,
                    hint: const Text('Filter status'),
                    items: const [
                      DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                      DropdownMenuItem(value: 'live', child: Text('Live')),
                      DropdownMenuItem(value: 'finished', child: Text('Finished')),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Search team/league'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _load, child: const Text('Apply')),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _matches.isEmpty
                    ? const Center(child: Text('No matches'))
                    : ListView.builder(
                        itemCount: _matches.length,
                        itemBuilder: (context, index) {
                          final m = _matches[index] as Map<String, dynamic>;
                          final odds = m['odds'] as Map<String, dynamic>?;
                          return Card(
                            color: const Color(0xFF1A1F2E),
                            child: ListTile(
                              title: Text(
                                '${m['home_team']?['name'] ?? 'Home'} vs ${m['away_team']?['name'] ?? 'Away'}',
                              ),
                              subtitle: Text(
                                '${m['status']} | close: ${m['bet_closes_at'] ?? '-'}\n'
                                'odds H:${odds?['home_win_odds'] ?? '-'} D:${odds?['draw_odds'] ?? '-'} A:${odds?['away_win_odds'] ?? '-'}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'finish-home') await _finish(m, 2, 1);
                                  if (value == 'finish-draw') await _finish(m, 1, 1);
                                  if (value == 'finish-away') await _finish(m, 1, 2);
                                  if (value == 'delete') {
                                    await _adminService.deleteMatch(m['id'].toString());
                                    await _load();
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'finish-home',
                                    child: Text('Finish home win'),
                                  ),
                                  PopupMenuItem(
                                    value: 'finish-draw',
                                    child: Text('Finish draw'),
                                  ),
                                  PopupMenuItem(
                                    value: 'finish-away',
                                    child: Text('Finish away win'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete test match'),
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
    );
  }
}
