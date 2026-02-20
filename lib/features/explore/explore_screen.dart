import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/widgets/bottom_nav_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9A3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.explore_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Advanced tools & insights',
                        style: TextStyle(
                          color: Color(0xFF8E92BC),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.emoji_events_outlined,
                    iconColor: const Color(0xFF00D9A3),
                    title: 'Competition Hub',
                    subtitle: 'Live standings, fixtures &\nleague analytics',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.competitionHub);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.timeline,
                    iconColor: const Color(0xFF00D9A3),
                    title: 'Advanced Match Insights',
                    subtitle: 'Deep dive into match statistics\n& patterns',
                    onTap: () {
                      // Navigate to Advanced Match Insights
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.psychology_outlined,
                    iconColor: const Color(0xFF00D9A3),
                    title: 'AI Prediction Center',
                    subtitle: 'Machine learning powered\nmatch predictions',
                    onTap: () {
                      // Navigate to AI Prediction Center
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFFFF8A65),
                    title: 'Market Movements',
                    subtitle: 'Real-time odds tracking &\nmarket analysis',
                    onTap: () {
                      // Navigate to Market Movements
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart,
                    iconColor: const Color(0xFF00D9A3),
                    title: 'Analytics Dashboard',
                    subtitle: 'Your betting performance &\nstatistics',
                    onTap: () {
                      // Navigate to Analytics Dashboard
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    iconColor: const Color(0xFF00D9A3),
                    title: 'Bet History Analytics',
                    subtitle: 'Detailed breakdown of your\nbetting patterns',
                    onTap: () {
                      // Navigate to Bet History Analytics
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.lightbulb_outline,
                    iconColor: const Color(0xFFFFB74D),
                    title: 'Strategy Builder',
                    subtitle: 'Create & test betting strategies\nwith AI',
                    onTap: () {
                      // Navigate to Strategy Builder
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, AppRoutes.home);
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8E92BC),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8E92BC),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
