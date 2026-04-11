import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/widgets/bottom_nav_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
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
                      color: context.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.explore_outlined,
                      color: context.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Advanced tools & insights',
                        style: TextStyle(
                          color: context.textSecondary,
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
                    iconColor: context.accent,
                    title: 'Competition Hub',
                    subtitle: 'Live standings, fixtures &\nleague analytics',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.competitionHub);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF6C63FF),
                    title: 'Players Hub',
                    subtitle: 'Player stats, rankings &\ngoal / assist charts',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.playersHub);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.timeline,
                    iconColor: context.accent,
                    title: 'Advanced Match Insights',
                    subtitle: 'Deep dive into match statistics\n& patterns',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.advancedMatchInsights);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.psychology_outlined,
                    iconColor: context.accent,
                    title: 'AI Prediction Center',
                    subtitle: 'Machine learning powered\nmatch predictions',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.aiPredictionCenter);
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
                      Navigator.pushNamed(
                          context, AppRoutes.marketMovements);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart,
                    iconColor: context.accent,
                    title: 'Analytics Dashboard',
                    subtitle: 'Your betting performance &\nstatistics',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.analyticsDashboard);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    iconColor: context.accent,
                    title: 'Bet History Analytics',
                    subtitle: 'Detailed breakdown of your\nbetting patterns',
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.betHistoryAnalytics);
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
                      Navigator.pushNamed(
                          context, AppRoutes.strategyBuilder);
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
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
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
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.iconInactive,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
