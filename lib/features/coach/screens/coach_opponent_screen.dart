import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';

class CoachOpponentScreen extends StatefulWidget {
  const CoachOpponentScreen({super.key});

  @override
  State<CoachOpponentScreen> createState() => _CoachOpponentScreenState();
}

class _CoachOpponentScreenState extends State<CoachOpponentScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;
  bool _isLoading = false;

  void _searchOpponent() {
    if (_searchController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          'Opponent X-Ray',
                          style: AppTextStyles.h3.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Know them before kickoff',
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
                      color: AppColors.chartBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: AppColors.chartBlue,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search opponent name...',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.iconInactive,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.chartBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onFieldSubmitted: (_) => _searchOpponent(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _searchOpponent,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.chartBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.radar,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.chartBlue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scanning opponent...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _hasSearched
                      ? _DossierContent()
                      : _EmptyState(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.chartBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.radar,
                color: AppColors.chartBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Search an opponent',
              style: AppTextStyles.h3.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the team name to generate their secret dossier',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dossier Content ─────────────────────────────────────────────────────────
class _DossierContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Opponent Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isDark
                    ? [const Color(0xFF1A2232), const Color(0xFF0F1923)]
                    : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.chartBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.chartBlue,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: AppColors.chartBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Al Ahly SC',
                  style: AppTextStyles.h2.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Egyptian Premier League',
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip('Form', 'WWDWL', AppColors.accentGreen),
                    _StatChip('Goals/Game', '1.8', AppColors.chartBlue),
                    _StatChip('Clean Sheets', '40%', AppColors.chartPurple),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Formation Section
          Text(
            'USUAL FORMATION',
            style: AppTextStyles.overline.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.chartBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '4-2-3-1',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.chartBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compact midfield',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Double pivot with high pressing',
                        style: AppTextStyles.caption.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Danger & Weak Zones
          Text(
            'ZONES ANALYSIS',
            style: AppTextStyles.overline.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ZoneCard(
                  title: 'Danger Zones',
                  icon: Icons.warning_amber,
                  color: AppColors.error,
                  zones: ['Right flank attacks', 'Set pieces (corners)'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ZoneCard(
                  title: 'Weak Zones',
                  icon: Icons.check_circle_outline,
                  color: AppColors.accentGreen,
                  zones: ['Left back exposed', 'Slow center backs'],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Key Player to Watch
          Text(
            'KEY PLAYER TO WATCH',
            style: AppTextStyles.overline.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: AppColors.accentOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mohamed Salah',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ST — 12 goals, 5 assists this season',
                        style: AppTextStyles.caption.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DANGER',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Counter Strategy
          Text(
            'SUGGESTED COUNTER-STRATEGY',
            style: AppTextStyles.overline.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                _StrategyItem(
                  icon: Icons.shield_outlined,
                  text: 'Use 3-5-2 to overload midfield',
                ),
                const SizedBox(height: 10),
                _StrategyItem(
                  icon: Icons.speed,
                  text: 'Exploit slow center backs with pace',
                ),
                const SizedBox(height: 10),
                _StrategyItem(
                  icon: Icons.person_off,
                  text: 'Man-mark Salah with dedicated defender',
                ),
                const SizedBox(height: 10),
                _StrategyItem(
                  icon: Icons.sports,
                  text: 'Target the left side — their RB pushes high',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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

class _ZoneCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> zones;

  const _ZoneCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.zones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...zones.map(
            (zone) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      zone,
                      style: AppTextStyles.caption.copyWith(
                        color: context.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategyItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StrategyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.accentGreen, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
