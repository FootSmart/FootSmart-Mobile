import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/coach_bottom_nav_bar.dart';

class CoachLiveConsoleScreen extends StatefulWidget {
  const CoachLiveConsoleScreen({super.key});

  @override
  State<CoachLiveConsoleScreen> createState() => _CoachLiveConsoleScreenState();
}

class _CoachLiveConsoleScreenState extends State<CoachLiveConsoleScreen> {
  int _matchMinute = 63;
  final List<_MatchEvent> _events = [
    _MatchEvent(Icons.sports_soccer, 'Goal — Ahmed (23\')', EventType.goal),
    _MatchEvent(
        Icons.square, 'Yellow Card — Opponent #7 (31\')', EventType.card),
    _MatchEvent(Icons.sports_soccer, 'Goal — Opponent #9 (41\')',
        EventType.goalAgainst),
    _MatchEvent(Icons.swap_horiz, 'Sub: Omar → Karim (46\')', EventType.sub),
  ];

  final List<_AISuggestion> _suggestions = [
    _AISuggestion(
      icon: Icons.swap_horiz,
      title: 'Substitute CM',
      detail: 'Youssef looks fatigued (stamina 34%). Consider bringing on Ali.',
      priority: 'HIGH',
    ),
    _AISuggestion(
      icon: Icons.shield,
      title: 'Switch to 5-4-1',
      detail: 'Opponent is pressing more. Protect the 1-1 score.',
      priority: 'MEDIUM',
    ),
    _AISuggestion(
      icon: Icons.access_time,
      title: 'Slow down pace',
      detail: 'Your team\'s intensity dropped 20% since min 55.',
      priority: 'LOW',
    ),
  ];

  void _addEvent(String label, EventType type) {
    setState(() {
      _events.add(_MatchEvent(
        type == EventType.goal
            ? Icons.sports_soccer
            : type == EventType.card
                ? Icons.square
                : Icons.swap_horiz,
        label,
        type,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Live Indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: context.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Console',
                          style: AppTextStyles.h3.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your sideline superpower',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Match Score Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: context.isDark
                        ? [const Color(0xFF1A2332), const Color(0xFF0F1923)]
                        : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFF2A3545)
                        : const Color(0xFF90CAF9),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ScoreTeam(name: 'Your Team', isHome: true),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Text(
                                '1 - 1',
                                style: AppTextStyles.h1.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.accentOrange
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_matchMinute\'',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.accentOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ScoreTeam(name: 'FC Rival', isHome: false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick event buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _EventButton(
                          icon: Icons.sports_soccer,
                          label: 'Goal',
                          color: AppColors.accentGreen,
                          onTap: () => _addEvent(
                              'Goal — Your Team ($_matchMinute\')',
                              EventType.goal),
                        ),
                        _EventButton(
                          icon: Icons.square,
                          label: 'Card',
                          color: AppColors.warning,
                          onTap: () => _addEvent(
                              'Yellow Card ($_matchMinute\')', EventType.card),
                        ),
                        _EventButton(
                          icon: Icons.swap_horiz,
                          label: 'Sub',
                          color: AppColors.chartBlue,
                          onTap: () => _addEvent(
                              'Substitution ($_matchMinute\')', EventType.sub),
                        ),
                        _EventButton(
                          icon: Icons.accessibility_new,
                          label: 'Tired',
                          color: AppColors.error,
                          onTap: () => _addEvent(
                              'Player tired ($_matchMinute\')', EventType.note),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AI Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.chartPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.chartPurple,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI SUGGESTIONS',
                    style: AppTextStyles.overline.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: suggestion.priority == 'HIGH'
                            ? AppColors.error.withValues(alpha: 0.4)
                            : suggestion.priority == 'MEDIUM'
                                ? AppColors.warning.withValues(alpha: 0.4)
                                : context.borderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              suggestion.icon,
                              color: suggestion.priority == 'HIGH'
                                  ? AppColors.error
                                  : suggestion.priority == 'MEDIUM'
                                      ? AppColors.warning
                                      : AppColors.chartBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                suggestion.title,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: suggestion.priority == 'HIGH'
                                    ? AppColors.error.withValues(alpha: 0.15)
                                    : suggestion.priority == 'MEDIUM'
                                        ? AppColors.warning
                                            .withValues(alpha: 0.15)
                                        : AppColors.chartBlue
                                            .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                suggestion.priority,
                                style: AppTextStyles.caption.copyWith(
                                  color: suggestion.priority == 'HIGH'
                                      ? AppColors.error
                                      : suggestion.priority == 'MEDIUM'
                                          ? AppColors.warning
                                          : AppColors.chartBlue,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            suggestion.detail,
                            style: AppTextStyles.caption.copyWith(
                              color: context.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Match Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'MATCH TIMELINE',
                style: AppTextStyles.overline.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event =
                      _events[_events.length - 1 - index]; // newest first
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                _eventColor(event.type).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            event.icon,
                            color: _eventColor(event.type),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            event.label,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CoachBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Color _eventColor(EventType type) {
    switch (type) {
      case EventType.goal:
        return AppColors.accentGreen;
      case EventType.goalAgainst:
        return AppColors.error;
      case EventType.card:
        return AppColors.warning;
      case EventType.sub:
        return AppColors.chartBlue;
      case EventType.note:
        return AppColors.chartPurple;
    }
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.coachHome);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.coachTactics);
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.coachPerfectPlayer);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }
}

// ─── Score Team Widget ───────────────────────────────────────────────────────
class _ScoreTeam extends StatelessWidget {
  final String name;
  final bool isHome;

  const _ScoreTeam({required this.name, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
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
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTextStyles.caption.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ─── Event Button Widget ─────────────────────────────────────────────────────
class _EventButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EventButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────────────────────
enum EventType { goal, goalAgainst, card, sub, note }

class _MatchEvent {
  final IconData icon;
  final String label;
  final EventType type;

  _MatchEvent(this.icon, this.label, this.type);
}

class _AISuggestion {
  final IconData icon;
  final String title;
  final String detail;
  final String priority;

  _AISuggestion({
    required this.icon,
    required this.title,
    required this.detail,
    required this.priority,
  });
}
