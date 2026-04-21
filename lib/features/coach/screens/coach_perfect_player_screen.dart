import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/coach_bottom_nav_bar.dart';

class CoachPerfectPlayerScreen extends StatefulWidget {
  const CoachPerfectPlayerScreen({super.key});

  @override
  State<CoachPerfectPlayerScreen> createState() =>
      _CoachPerfectPlayerScreenState();
}

class _CoachPerfectPlayerScreenState extends State<CoachPerfectPlayerScreen> {
  // Use ValueNotifier so slider dragging only rebuilds the radar + slider area
  final _statsNotifier =
      ValueNotifier<List<double>>([0.7, 0.6, 0.8, 0.3, 0.65, 0.75]);
  bool _showResult = false;

  double get _speed => _statsNotifier.value[0];
  double get _passing => _statsNotifier.value[1];
  double get _shooting => _statsNotifier.value[2];
  double get _defending => _statsNotifier.value[3];
  double get _stamina => _statsNotifier.value[4];
  double get _dribbling => _statsNotifier.value[5];

  void _updateStat(int index, double value) {
    final updated = List<double>.from(_statsNotifier.value);
    updated[index] = value;
    _statsNotifier.value = updated;
  }

  String get _suggestedPosition {
    if (_shooting > 0.7 && _speed > 0.6) return 'Striker (ST)';
    if (_passing > 0.7 && _stamina > 0.6) return 'Central Midfielder (CM)';
    if (_defending > 0.7 && _stamina > 0.6) return 'Center Back (CB)';
    if (_speed > 0.8 && _dribbling > 0.7) return 'Winger (LW/RW)';
    if (_defending > 0.5 && _speed > 0.6) return 'Full Back (LB/RB)';
    return 'Attacking Midfielder (AM)';
  }

  void _generateProfile() {
    setState(() {
      _showResult = true;
    });
  }

  @override
  void dispose() {
    _statsNotifier.dispose();
    super.dispose();
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
                            'Build Perfect Player',
                            style: AppTextStyles.h3.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Design your dream signing',
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
                        color: AppColors.chartPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.chartPurple,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Player Silhouette Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: context.isDark
                          ? [const Color(0xFF1E1A2E), const Color(0xFF15112A)]
                          : [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.chartPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Hexagonal stat display (simplified as radial)
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: ValueListenableBuilder<List<double>>(
                          valueListenable: _statsNotifier,
                          builder: (context, stats, _) {
                            return RepaintBoundary(
                              child: CustomPaint(
                                painter: _RadarChartPainter(
                                  stats: stats,
                                  labels: const [
                                    'SPD',
                                    'PAS',
                                    'SHT',
                                    'DEF',
                                    'STA',
                                    'DRI',
                                  ],
                                  accentColor: AppColors.chartPurple,
                                  textColor: context.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_showResult)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.chartPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Best Position: $_suggestedPosition',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.chartPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stat Sliders
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'ADJUST ATTRIBUTES',
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
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: ValueListenableBuilder<List<double>>(
                    valueListenable: _statsNotifier,
                    builder: (context, stats, _) {
                      return Column(
                        children: [
                          _StatSlider(
                            label: 'Speed',
                            value: stats[0],
                            icon: Icons.speed,
                            color: AppColors.accentOrange,
                            onChanged: (v) => _updateStat(0, v),
                          ),
                          _StatSlider(
                            label: 'Passing',
                            value: stats[1],
                            icon: Icons.share,
                            color: AppColors.chartBlue,
                            onChanged: (v) => _updateStat(1, v),
                          ),
                          _StatSlider(
                            label: 'Shooting',
                            value: stats[2],
                            icon: Icons.gps_fixed,
                            color: AppColors.error,
                            onChanged: (v) => _updateStat(2, v),
                          ),
                          _StatSlider(
                            label: 'Defending',
                            value: stats[3],
                            icon: Icons.shield,
                            color: AppColors.accentGreen,
                            onChanged: (v) => _updateStat(3, v),
                          ),
                          _StatSlider(
                            label: 'Stamina',
                            value: stats[4],
                            icon: Icons.battery_charging_full,
                            color: AppColors.warning,
                            onChanged: (v) => _updateStat(4, v),
                          ),
                          _StatSlider(
                            label: 'Dribbling',
                            value: stats[5],
                            icon: Icons.gesture,
                            color: AppColors.chartPurple,
                            onChanged: (v) => _updateStat(5, v),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Generate Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _generateProfile,
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: Text(
                      'Generate Player Profile',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: context.isDark
                            ? AppColors.primaryDark
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chartPurple,
                      foregroundColor:
                          context.isDark ? AppColors.primaryDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Squad Match Result
              if (_showResult) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'CLOSEST IN YOUR SQUAD',
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
                  child: _SquadMatchCard(
                    name: 'Ahmed El-Sharkawy',
                    position: 'Striker',
                    matchPercent: 78,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SquadMatchCard(
                    name: 'Karim Benzaoui',
                    position: 'Attacking Mid',
                    matchPercent: 64,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SquadMatchCard(
                    name: 'Omar Fathi',
                    position: 'Left Wing',
                    matchPercent: 52,
                  ),
                ),

                const SizedBox(height: 20),

                // Save as Target
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Saved as transfer target profile!'),
                          backgroundColor: AppColors.chartPurple,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    label: const Text('Save as Target Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.chartPurple,
                      side: const BorderSide(color: AppColors.chartPurple),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
      bottomNavigationBar: CoachBottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        AppRoutes.replace(context, AppRoutes.coachHome);
        break;
      case 1:
        AppRoutes.replace(context, AppRoutes.coachTactics);
        break;
      case 2:
        AppRoutes.replace(context, AppRoutes.coachLiveConsole);
        break;
      case 3:
        break;
      case 4:
        AppRoutes.push(context, AppRoutes.profile);
        break;
    }
  }
}

// ─── Stat Slider ─────────────────────────────────────────────────────────────
class _StatSlider extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final ValueChanged<double> onChanged;

  const _StatSlider({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Icon(icon, color: color, size: 18),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: context.borderColor,
                thumbColor: color,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).round()}',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Squad Match Card ────────────────────────────────────────────────────────
class _SquadMatchCard extends StatelessWidget {
  final String name;
  final String position;
  final int matchPercent;

  const _SquadMatchCard({
    required this.name,
    required this.position,
    required this.matchPercent,
  });

  @override
  Widget build(BuildContext context) {
    final matchColor = matchPercent >= 70
        ? AppColors.accentGreen
        : matchPercent >= 50
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.inputBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: context.iconInactive,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  position,
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: matchColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$matchPercent% Match',
              style: AppTextStyles.bodySmall.copyWith(
                color: matchColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Radar Chart Painter ─────────────────────────────────────────────────────
class _RadarChartPainter extends CustomPainter {
  final List<double> stats;
  final List<String> labels;
  final Color accentColor;
  final Color textColor;

  _RadarChartPainter({
    required this.stats,
    required this.labels,
    required this.accentColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    final sides = stats.length;
    final angle = 2 * math.pi / sides;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = textColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final path = Path();
      final levelRadius = radius * (level / 4);
      for (int i = 0; i <= sides; i++) {
        final a = -math.pi / 2 + angle * i;
        final x = center.dx + levelRadius * math.cos(a);
        final y = center.dy + levelRadius * math.sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    // Draw spokes
    for (int i = 0; i < sides; i++) {
      final a = -math.pi / 2 + angle * i;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(a),
          center.dy + radius * math.sin(a),
        ),
        gridPaint,
      );
    }

    // Draw stat polygon
    final statPath = Path();
    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i <= sides; i++) {
      final idx = i % sides;
      final a = -math.pi / 2 + angle * idx;
      final r = radius * stats[idx];
      final x = center.dx + r * math.cos(a);
      final y = center.dy + r * math.sin(a);
      if (i == 0) {
        statPath.moveTo(x, y);
      } else {
        statPath.lineTo(x, y);
      }
    }
    canvas.drawPath(statPath, fillPaint);
    canvas.drawPath(statPath, strokePaint);

    // Draw stat dots
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sides; i++) {
      final a = -math.pi / 2 + angle * i;
      final r = radius * stats[i];
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        4,
        dotPaint,
      );
    }

    // Draw labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < sides; i++) {
      final a = -math.pi / 2 + angle * i;
      final labelRadius = radius + 18;
      final x = center.dx + labelRadius * math.cos(a);
      final y = center.dy + labelRadius * math.sin(a);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: textColor.withValues(alpha: 0.7),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return !listEquals(oldDelegate.stats, stats) ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.textColor != textColor;
  }
}
