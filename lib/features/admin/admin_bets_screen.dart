import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/services/admin_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/features/admin/admin_refresh_bus.dart';

class AdminBetsScreen extends StatefulWidget {
  const AdminBetsScreen({super.key});

  @override
  State<AdminBetsScreen> createState() => _AdminBetsScreenState();
}

class _AdminBetsScreenState extends State<AdminBetsScreen> {
  final AdminService _adminService = AdminService(ApiService());
  late final VoidCallback _refreshListener;
  String _status = '';
  bool _isLoading = true;
  List<dynamic> _bets = [];

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
    AdminRefreshBus.tick.removeListener(_refreshListener);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _adminService.getAdminBets(
        status: _status.isEmpty ? null : _status,
      );
      if (!mounted) return;
      setState(() => _bets = res['bets'] as List<dynamic>? ?? []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load bets: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _runSettlement() async {
    try {
      final res = await _adminService.runSettlement();
      if (!mounted) return;
      AdminRefreshBus.notifyUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Settlement done')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Settlement failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text('Admin Bets'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _runSettlement, icon: const Icon(Icons.play_arrow)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _status.isEmpty ? null : _status,
              hint: const Text('Filter status'),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'won', child: Text('Won')),
                DropdownMenuItem(value: 'lost', child: Text('Lost')),
              ],
              onChanged: (value) {
                setState(() => _status = value ?? '');
                _load();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bets.isEmpty
                    ? const Center(child: Text('No bets'))
                    : ListView.builder(
                        itemCount: _bets.length,
                        itemBuilder: (context, index) {
                          final b = _bets[index] as Map<String, dynamic>;
                          return Card(
                            color: const Color(0xFF1A1F2E),
                            child: ListTile(
                              title: Text('${b['match']} • ${b['user_email']}'),
                              subtitle: Text(
                                'stake: ${b['stake']} | odds: ${b['odds']} | payout: ${b['potential_payout']}\n'
                                'status: ${b['status']} | created: ${b['created_at']}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runSettlement,
        label: const Text('Run settlement'),
        icon: const Icon(Icons.check_circle_outline),
      ),
    );
  }
}
