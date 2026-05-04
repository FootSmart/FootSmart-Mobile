import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/services/admin_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService(ApiService());
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final res = await _adminService.getUsers(search: _searchController.text);
      if (!mounted) return;
      setState(() => _users = (res['users'] as List<dynamic>? ?? []));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAction(String title, Future<void> Function() action) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await action();
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text('Admin Users'),
        actions: [IconButton(onPressed: _loadUsers, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by email/display name',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index] as Map<String, dynamic>;
                          final userId = user['id']?.toString() ?? '';
                          return Card(
                            color: const Color(0xFF1A1F2E),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['email']?.toString() ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Role: ${user['role']} • Status: ${user['account_status']} • Points: ${user['points']}',
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _confirmAction(
                                          'Reset points',
                                          () => _adminService.resetUserPoints(
                                            userId,
                                            1000,
                                          ),
                                        ),
                                        child: const Text('Reset points'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _confirmAction(
                                          'Suspend user',
                                          () => _adminService.updateUserStatus(
                                            userId,
                                            'suspended',
                                          ),
                                        ),
                                        child: const Text('Suspend'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _confirmAction(
                                          'Activate user',
                                          () => _adminService.updateUserStatus(
                                            userId,
                                            'active',
                                          ),
                                        ),
                                        child: const Text('Activate'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _confirmAction(
                                          'Make admin',
                                          () => _adminService.updateUserRole(
                                            userId,
                                            'admin',
                                          ),
                                        ),
                                        child: const Text('Make admin'),
                                      ),
                                    ],
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
