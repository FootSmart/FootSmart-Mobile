import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/services/admin_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/features/admin/admin_refresh_bus.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService(ApiService());
  late final VoidCallback _refreshListener;
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

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
      final data = await _adminService.getDashboard();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _card(String title, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3248)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFFA0A4B8), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF00C896),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total users', _data['usersCount'] ?? 0),
      ('Active users', _data['activeUsersCount'] ?? 0),
      ('Total matches', _data['totalMatches'] ?? 0),
      ('Scheduled matches', _data['scheduledMatches'] ?? 0),
      ('Finished matches', _data['finishedMatches'] ?? 0),
      ('Total bets', _data['totalBets'] ?? 0),
      ('Pending bets', _data['pendingBets'] ?? 0),
      ('Won bets', _data['wonBets'] ?? 0),
      ('Lost bets', _data['lostBets'] ?? 0),
      ('Total points', _data['totalPointsInSystem'] ?? 0),
      ('Total staked', _data['totalStaked'] ?? 0),
      ('Total paid out', _data['totalPaidOut'] ?? 0),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'users') AppRoutes.push(context, AppRoutes.adminUsers);
              if (value == 'matches') AppRoutes.push(context, AppRoutes.adminMatches);
              if (value == 'bets') AppRoutes.push(context, AppRoutes.adminBets);
              if (value == 'lab') AppRoutes.push(context, AppRoutes.adminTestLab);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'users', child: Text('Users')),
              PopupMenuItem(value: 'matches', child: Text('Matches')),
              PopupMenuItem(value: 'bets', child: Text('Bets')),
              PopupMenuItem(value: 'lab', child: Text('Test Lab')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, index) =>
                    _card(items[index].$1, items[index].$2),
              ),
            ),
    );
  }
}
