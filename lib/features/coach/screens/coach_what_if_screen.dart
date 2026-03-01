import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';

class CoachWhatIfScreen extends StatefulWidget {
  const CoachWhatIfScreen({super.key});

  @override
  State<CoachWhatIfScreen> createState() => _CoachWhatIfScreenState();
}

class _CoachWhatIfScreenState extends State<CoachWhatIfScreen> {
  int _selectedMatchIndex = 0;
  String? _selectedChange;
  bool _showResult = false;

  final List<_PastMatch> _pastMatches = [
    _PastMatch('Your Team', 'FC Rival', '1 - 2', 'Loss', 'Feb 22, 2026'),
    _PastMatch('Your Team', 'City United', '0 - 0', 'Draw', 'Feb 15, 2026'),
    _PastMatch('Your Team', 'AC Stars', '3 - 1', 'Win', 'Feb 8, 2026'),
  ];

  final List<_WhatIfOption> _whatIfOptions = [
    _WhatIfOption(
      icon: Icons.swap_horiz,
      label: 'Change Formation',
      detail: 'Switch from 4-3-3 to 3-5-2',
    ),
    _WhatIfOption(
      icon: Icons.published_with_changes,
      label: 'Earlier Substitution',
      detail: 'Bring on striker at 60\' instead of 75\'',
    ),
    _WhatIfOption(
      icon: Icons.sports,
      label: 'Different Pressing',
      detail: 'High press instead of low block',
    ),
    _WhatIfOption(
      icon: Icons.person_add,
      label: 'Different Starter',
      detail: 'Start Ahmed instead of Omar',
    ),
  ];

  void _simulateChange(String change) {
    setState(() {
      _selectedChange = change;
      _showResult = false;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showResult = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                            'What If Room',
                            style: AppTextStyles.h3.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rewrite your matches',
                            style: AppTextStyles.caption.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.replay_circle_filled,
                        color: AppColors.accentOrange,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Past Matches Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'SELECT A MATCH',
                  style: AppTextStyles.overline.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _pastMatches.length,
                  itemBuilder: (context, index) {
                    final match = _pastMatches[index];
                    final isSelected = _selectedMatchIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMatchIndex = index;
                          _selectedChange = null;
                          _showResult = false;
                        });
                      },
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.accentOrange.withValues(alpha: 0.1)
                              : context.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.accentOrange
                                : context.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  match.score,
                                  style: AppTextStyles.h3.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: match.result == 'Win'
                                        ? AppColors.accentGreen
                                            .withValues(alpha: 0.15)
                                        : match.result == 'Loss'
                                            ? AppColors.error
                                                .withValues(alpha: 0.15)
                                            : AppColors.warning
                                                .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    match.result,
                                    style: AppTextStyles.caption.copyWith(
                                      color: match.result == 'Win'
                                          ? AppColors.accentGreen
                                          : match.result == 'Loss'
                                              ? AppColors.error
                                              : AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'vs ${match.opponent}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  match.date,
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.textTertiary,
                                    fontSize: 10,
                                  ),
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

              const SizedBox(height: 24),

              // What If Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'CHANGE ONE DECISION',
                  style: AppTextStyles.overline.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _whatIfOptions.map((option) {
                    final isSelected = _selectedChange == option.label;
                    return GestureDetector(
                      onTap: () => _simulateChange(option.label),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.accentOrange.withValues(alpha: 0.1)
                              : context.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.accentOrange
                                : context.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.accentOrange
                                        .withValues(alpha: 0.2)
                                    : context.inputBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                option.icon,
                                color: isSelected
                                    ? context.accentOrange
                                    : context.iconInactive,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    option.detail,
                                    style: AppTextStyles.caption.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: context.accentOrange,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Simulation Result
              if (_selectedChange != null) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'SIMULATION RESULT',
                    style: AppTextStyles.overline.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedOpacity(
                    opacity: _showResult ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: context.isDark
                              ? [
                                  const Color(0xFF1A2E1A),
                                  const Color(0xFF0F1F0F),
                                ]
                              : [
                                  const Color(0xFFE8F5E9),
                                  const Color(0xFFC8E6C9),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Your Team',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '2 - 1',
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                _pastMatches[_selectedMatchIndex].opponent,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Probable Win — 72% confidence',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'The formation switch would have given more midfield control. '
                            'Your team would likely score from set pieces with better positioning.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Lesson saved to notebook!'),
                                  backgroundColor: context.accentOrange,
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_border, size: 18),
                            label: const Text('Save Lesson'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.accentOrange,
                              side: BorderSide(color: context.accentOrange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastMatch {
  final String team;
  final String opponent;
  final String score;
  final String result;
  final String date;

  _PastMatch(this.team, this.opponent, this.score, this.result, this.date);
}

class _WhatIfOption {
  final IconData icon;
  final String label;
  final String detail;

  _WhatIfOption({
    required this.icon,
    required this.label,
    required this.detail,
  });
}
