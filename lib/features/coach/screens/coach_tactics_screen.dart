import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/coach_bottom_nav_bar.dart';

class CoachTacticsScreen extends StatefulWidget {
  const CoachTacticsScreen({super.key});

  @override
  State<CoachTacticsScreen> createState() => _CoachTacticsScreenState();
}

class _CoachTacticsScreenState extends State<CoachTacticsScreen> {
  String _selectedFormation = '4-3-3';
  String _selectedPlan = 'Plan A';
  bool _isDrawingMode = false;

  final List<String> _formations = [
    '4-3-3',
    '4-4-2',
    '3-5-2',
    '4-2-3-1',
    '5-3-2',
    '3-4-3',
  ];

  // Player positions for 4-3-3 (normalized 0-1 on pitch)
  // Using ValueNotifier so only the pitch area rebuilds during drag
  late final ValueNotifier<List<_PlayerPosition>> _playersNotifier;

  @override
  void initState() {
    super.initState();
    _playersNotifier =
        ValueNotifier(_getFormationPositions(_selectedFormation));
  }

  @override
  void dispose() {
    _playersNotifier.dispose();
    super.dispose();
  }

  List<_PlayerPosition> _getFormationPositions(String formation) {
    switch (formation) {
      case '4-3-3':
        return [
          _PlayerPosition('GK', 0.5, 0.92, 'Goalkeeper'),
          _PlayerPosition('LB', 0.15, 0.75, 'Left Back'),
          _PlayerPosition('CB', 0.38, 0.78, 'Center Back'),
          _PlayerPosition('CB', 0.62, 0.78, 'Center Back'),
          _PlayerPosition('RB', 0.85, 0.75, 'Right Back'),
          _PlayerPosition('CM', 0.25, 0.55, 'Left Mid'),
          _PlayerPosition('CM', 0.5, 0.50, 'Center Mid'),
          _PlayerPosition('CM', 0.75, 0.55, 'Right Mid'),
          _PlayerPosition('LW', 0.18, 0.28, 'Left Wing'),
          _PlayerPosition('ST', 0.5, 0.20, 'Striker'),
          _PlayerPosition('RW', 0.82, 0.28, 'Right Wing'),
        ];
      case '4-4-2':
        return [
          _PlayerPosition('GK', 0.5, 0.92, 'Goalkeeper'),
          _PlayerPosition('LB', 0.15, 0.75, 'Left Back'),
          _PlayerPosition('CB', 0.38, 0.78, 'Center Back'),
          _PlayerPosition('CB', 0.62, 0.78, 'Center Back'),
          _PlayerPosition('RB', 0.85, 0.75, 'Right Back'),
          _PlayerPosition('LM', 0.15, 0.52, 'Left Mid'),
          _PlayerPosition('CM', 0.38, 0.55, 'Center Mid'),
          _PlayerPosition('CM', 0.62, 0.55, 'Center Mid'),
          _PlayerPosition('RM', 0.85, 0.52, 'Right Mid'),
          _PlayerPosition('ST', 0.38, 0.22, 'Striker'),
          _PlayerPosition('ST', 0.62, 0.22, 'Striker'),
        ];
      case '3-5-2':
        return [
          _PlayerPosition('GK', 0.5, 0.92, 'Goalkeeper'),
          _PlayerPosition('CB', 0.25, 0.78, 'Center Back'),
          _PlayerPosition('CB', 0.5, 0.80, 'Center Back'),
          _PlayerPosition('CB', 0.75, 0.78, 'Center Back'),
          _PlayerPosition('LWB', 0.1, 0.55, 'Left Wing Back'),
          _PlayerPosition('CM', 0.32, 0.52, 'Center Mid'),
          _PlayerPosition('CM', 0.5, 0.48, 'Center Mid'),
          _PlayerPosition('CM', 0.68, 0.52, 'Center Mid'),
          _PlayerPosition('RWB', 0.9, 0.55, 'Right Wing Back'),
          _PlayerPosition('ST', 0.38, 0.22, 'Striker'),
          _PlayerPosition('ST', 0.62, 0.22, 'Striker'),
        ];
      case '4-2-3-1':
        return [
          _PlayerPosition('GK', 0.5, 0.92, 'Goalkeeper'),
          _PlayerPosition('LB', 0.15, 0.75, 'Left Back'),
          _PlayerPosition('CB', 0.38, 0.78, 'Center Back'),
          _PlayerPosition('CB', 0.62, 0.78, 'Center Back'),
          _PlayerPosition('RB', 0.85, 0.75, 'Right Back'),
          _PlayerPosition('CDM', 0.38, 0.58, 'Def. Mid'),
          _PlayerPosition('CDM', 0.62, 0.58, 'Def. Mid'),
          _PlayerPosition('LW', 0.18, 0.38, 'Left Wing'),
          _PlayerPosition('AM', 0.5, 0.35, 'Att. Mid'),
          _PlayerPosition('RW', 0.82, 0.38, 'Right Wing'),
          _PlayerPosition('ST', 0.5, 0.18, 'Striker'),
        ];
      case '5-3-2':
        return [
          _PlayerPosition('GK', 0.5, 0.92, 'Goalkeeper'),
          _PlayerPosition('LWB', 0.08, 0.68, 'Left Wing Back'),
          _PlayerPosition('CB', 0.28, 0.78, 'Center Back'),
          _PlayerPosition('CB', 0.5, 0.80, 'Center Back'),
          _PlayerPosition('CB', 0.72, 0.78, 'Center Back'),
          _PlayerPosition('RWB', 0.92, 0.68, 'Right Wing Back'),
          _PlayerPosition('CM', 0.3, 0.52, 'Center Mid'),
          _PlayerPosition('CM', 0.5, 0.48, 'Center Mid'),
          _PlayerPosition('CM', 0.7, 0.52, 'Center Mid'),
          _PlayerPosition('ST', 0.38, 0.22, 'Striker'),
          _PlayerPosition('ST', 0.62, 0.22, 'Striker'),
        ];
      case '3-4-3':
        return [
          _PlayerPosition('GK', 0.5, 0.92, 'Goalkeeper'),
          _PlayerPosition('CB', 0.25, 0.78, 'Center Back'),
          _PlayerPosition('CB', 0.5, 0.80, 'Center Back'),
          _PlayerPosition('CB', 0.75, 0.78, 'Center Back'),
          _PlayerPosition('LM', 0.15, 0.52, 'Left Mid'),
          _PlayerPosition('CM', 0.38, 0.55, 'Center Mid'),
          _PlayerPosition('CM', 0.62, 0.55, 'Center Mid'),
          _PlayerPosition('RM', 0.85, 0.52, 'Right Mid'),
          _PlayerPosition('LW', 0.2, 0.25, 'Left Wing'),
          _PlayerPosition('ST', 0.5, 0.20, 'Striker'),
          _PlayerPosition('RW', 0.8, 0.25, 'Right Wing'),
        ];
      default:
        return _getFormationPositions('4-3-3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
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
                          'Tactics Board',
                          style: AppTextStyles.h3.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'The Lab — Design your game',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Drawing mode toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDrawingMode = !_isDrawingMode;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isDrawingMode
                            ? context.accentOrange.withValues(alpha: 0.2)
                            : context.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isDrawingMode
                              ? context.accentOrange
                              : context.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.gesture,
                        color: _isDrawingMode
                            ? context.accentOrange
                            : context.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Plan Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['Plan A', 'Plan B', 'Plan C'].map((plan) {
                  final isSelected = _selectedPlan == plan;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPlan = plan),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.accentOrange
                              : context.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? context.accentOrange
                                : context.borderColor,
                          ),
                        ),
                        child: Text(
                          plan,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? (context.isDark
                                    ? AppColors.primaryDark
                                    : Colors.white)
                                : context.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Formation Selector
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _formations.map((formation) {
                  final isSelected = _selectedFormation == formation;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFormation = formation;
                          _playersNotifier.value =
                              _getFormationPositions(formation);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.accentOrange.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? context.accentOrange
                                : context.borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          formation,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? context.accentOrange
                                : context.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Football Pitch
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D8B4E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CustomPaint(
                          painter: _PitchPainter(),
                          child: ValueListenableBuilder<List<_PlayerPosition>>(
                            valueListenable: _playersNotifier,
                            builder: (context, players, _) {
                              return Stack(
                                children: players.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final player = entry.value;
                                  final dx = player.x * constraints.maxWidth;
                                  final dy = player.y * constraints.maxHeight;

                                  return Positioned(
                                    left: dx - 22,
                                    top: dy - 22,
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        final newX = (dx + details.delta.dx) /
                                            constraints.maxWidth;
                                        final newY = (dy + details.delta.dy) /
                                            constraints.maxHeight;
                                        final updated =
                                            List<_PlayerPosition>.from(players);
                                        updated[idx] = _PlayerPosition(
                                          player.label,
                                          newX.clamp(0.05, 0.95),
                                          newY.clamp(0.05, 0.95),
                                          player.name,
                                        );
                                        _playersNotifier.value = updated;
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: idx == 0
                                                  ? AppColors.accentOrange
                                                  : Colors.white,
                                              border: Border.all(
                                                color: idx == 0
                                                    ? Colors.white
                                                    : AppColors.accentOrange,
                                                width: 2,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x40000000),
                                                  blurRadius: 3,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                player.label,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: idx == 0
                                                      ? Colors.white
                                                      : AppColors.primaryDark,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              player.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 7,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Formation saved!'),
                            backgroundColor: context.accentOrange,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save, size: 18),
                      label: Text(
                        'Save $_selectedPlan',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: context.isDark
                              ? AppColors.primaryDark
                              : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.accentOrange,
                        foregroundColor: context.isDark
                            ? AppColors.primaryDark
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Shared to squad! Players can view it now.'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.share,
                        color: context.iconColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CoachBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.coachHome);
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.coachLiveConsole);
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

class _PlayerPosition {
  final String label;
  final double x;
  final double y;
  final String name;

  _PlayerPosition(this.label, this.x, this.y, this.name);
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.15,
      paint,
    );

    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;

    // Top penalty area
    final topPenaltyRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.08),
      width: size.width * 0.55,
      height: size.height * 0.16,
    );
    canvas.drawRect(topPenaltyRect, paint);

    // Top goal area
    final topGoalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.03),
      width: size.width * 0.3,
      height: size.height * 0.06,
    );
    canvas.drawRect(topGoalRect, paint);

    // Bottom penalty area
    final bottomPenaltyRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.92),
      width: size.width * 0.55,
      height: size.height * 0.16,
    );
    canvas.drawRect(bottomPenaltyRect, paint);

    // Bottom goal area
    final bottomGoalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.97),
      width: size.width * 0.3,
      height: size.height * 0.06,
    );
    canvas.drawRect(bottomGoalRect, paint);

    // Pitch stripes (subtle)
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            0,
            i * size.height / 10,
            size.width,
            size.height / 10,
          ),
          stripePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
