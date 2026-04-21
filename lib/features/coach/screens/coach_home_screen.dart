import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/coach_bottom_nav_bar.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'War Room',
                          style: AppTextStyles.h1.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Command your game, Coach',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: context.iconColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Next Match Countdown Card
                _NextMatchCard(),

                const SizedBox(height: 20),

                // Team Mood Ring
                _TeamMoodCard(),

                const SizedBox(height: 20),

                // AI Daily Briefing Card
                _AIDailyBriefing(),

                const SizedBox(height: 20),

                // Quick Actions Grid
                Text(
                  'QUICK ACTIONS',
                  style: AppTextStyles.overline.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickActionsGrid(),

                const SizedBox(height: 20),

                // Recent Activity
                Text(
                  'RECENT ACTIVITY',
                  style: AppTextStyles.overline.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _RecentActivityList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CoachBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break; // Already here
      case 1:
        AppRoutes.push(context, AppRoutes.coachTactics);
        break;
      case 2:
        AppRoutes.push(context, AppRoutes.coachLiveConsole);
        break;
      case 3:
        AppRoutes.push(context, AppRoutes.coachPerfectPlayer);
        break;
      case 4:
        AppRoutes.push(context, AppRoutes.profile);
        break;
    }
  }
}

// ─── Next Match Countdown Card ───────────────────────────────────────────────
class _NextMatchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDark
              ? [const Color(0xFF1A2332), const Color(0xFF0F1923)]
              : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF2A3545)
              : const Color(0xFFFFCC80),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_soccer,
                color: context.accentOrange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'NEXT MATCH',
                style: AppTextStyles.overline.copyWith(
                  color: context.accentOrange,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TeamBadge(name: 'Your Team', isHome: true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'VS',
                      style: AppTextStyles.h2.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saturday 18:00',
                      style: AppTextStyles.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TeamBadge(name: 'Opponent', isHome: false),
            ],
          ),
          const SizedBox(height: 20),
          // Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountdownUnit(value: '02', label: 'Days'),
              _CountdownSeparator(),
              _CountdownUnit(value: '14', label: 'Hrs'),
              _CountdownSeparator(),
              _CountdownUnit(value: '37', label: 'Min'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  final String name;
  final bool isHome;

  const _TeamBadge({required this.name, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: context.inputBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isHome ? context.accentOrange : context.borderColor,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.shield,
            color: isHome ? context.accentOrange : context.textSecondary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTextStyles.caption.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: context.accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: context.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: AppTextStyles.h2.copyWith(
          color: context.accentOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Team Mood Card ──────────────────────────────────────────────────────────
class _TeamMoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moods = [
      _MoodEntry('Ahmed', '🔥', 'On Fire'),
      _MoodEntry('Youssef', '💪', 'Strong'),
      _MoodEntry('Karim', '😴', 'Tired'),
      _MoodEntry('Omar', '🔥', 'On Fire'),
      _MoodEntry('Ali', '😤', 'Focused'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Mood Ring',
                style: AppTextStyles.h4.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '80% Ready',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods
                .map(
                  (mood) => Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: context.borderColor, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood.name,
                        style: AppTextStyles.caption.copyWith(
                          color: context.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        mood.label,
                        style: AppTextStyles.caption.copyWith(
                          color: context.textTertiary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MoodEntry {
  final String name;
  final String emoji;
  final String label;

  _MoodEntry(this.name, this.emoji, this.label);
}

// ─── AI Daily Briefing ───────────────────────────────────────────────────────
class _AIDailyBriefing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDark
              ? [const Color(0xFF1E1A2E), const Color(0xFF15112A)]
              : [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF3A2D5C)
              : const Color(0xFFCE93D8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.chartPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.chartPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Daily Briefing',
                style: AppTextStyles.h4.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"Your team concedes 68% of goals in the last 15 minutes. Consider late defensive substitutions."',
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.chartPurple,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Based on your last 10 matches',
                style: AppTextStyles.caption.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions Grid ──────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.draw,
        label: 'Build Lineup',
        color: context.accentOrange,
        route: AppRoutes.coachTactics,
      ),
      _QuickAction(
        icon: Icons.visibility,
        label: 'Opponent X-Ray',
        color: AppColors.chartBlue,
        route: AppRoutes.coachOpponent,
      ),
      _QuickAction(
        icon: Icons.psychology,
        label: 'Perfect Player',
        color: AppColors.chartPurple,
        route: AppRoutes.coachPerfectPlayer,
      ),
      _QuickAction(
        icon: Icons.campaign,
        label: 'Squad Broadcast',
        color: AppColors.accentGreen,
        route: AppRoutes.coachBroadcast,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => AppRoutes.push(context, action.route),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  action.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

// ─── Recent Activity List ────────────────────────────────────────────────────
class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(
        icon: Icons.draw,
        title: 'Saved formation 4-3-3',
        time: '2h ago',
        color: context.accentOrange,
      ),
      _Activity(
        icon: Icons.visibility,
        title: 'Scouted opponent: Al Ahly',
        time: '5h ago',
        color: AppColors.chartBlue,
      ),
      _Activity(
        icon: Icons.campaign,
        title: 'Broadcast: Lineup for Saturday',
        time: 'Yesterday',
        color: AppColors.accentGreen,
      ),
    ];

    return Column(
      children: activities
          .map(
            (activity) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: activity.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          activity.time,
                          style: AppTextStyles.caption.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.iconInactive,
                    size: 20,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Activity {
  final IconData icon;
  final String title;
  final String time;
  final Color color;

  _Activity({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
  });
}
