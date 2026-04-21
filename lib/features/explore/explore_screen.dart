import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/theme/app_colors.dart';
import 'package:footsmart_pro/core/theme/app_radius.dart';
import 'package:footsmart_pro/core/theme/app_spacing.dart';
import 'package:footsmart_pro/core/utils/responsive.dart';
import 'package:footsmart_pro/shared/widgets/app_badge.dart';
import 'package:footsmart_pro/shared/widgets/app_card.dart';
import 'package:footsmart_pro/shared/widgets/app_text.dart';
import 'package:footsmart_pro/widgets/bottom_nav_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const List<_ExploreFeature> _features = [
    _ExploreFeature(
      title: 'Competition Hub',
      subtitle: 'Live standings, fixtures, and league analytics.',
      icon: Icons.emoji_events_outlined,
      route: AppRoutes.competitionHub,
      tone: _FeatureTone.accent,
    ),
    _ExploreFeature(
      title: 'Players Hub',
      subtitle: 'Rankings, assist charts, and player impact form.',
      icon: Icons.people_alt_rounded,
      route: AppRoutes.playersHub,
      tone: _FeatureTone.violet,
    ),
    _ExploreFeature(
      title: 'Match Insights',
      subtitle: 'Pattern recognition, momentum shifts, and matchup edges.',
      icon: Icons.timeline,
      route: AppRoutes.advancedMatchInsights,
      tone: _FeatureTone.info,
    ),
    _ExploreFeature(
      title: 'AI Prediction Center',
      subtitle: 'Model confidence, scenario cards, and key risk factors.',
      icon: Icons.psychology_outlined,
      route: AppRoutes.aiPredictionCenter,
      tone: _FeatureTone.accent,
      badge: 'AI',
    ),
    _ExploreFeature(
      title: 'Market Movements',
      subtitle: 'Odds volatility tracking and sharp-money pressure map.',
      icon: Icons.trending_up,
      route: AppRoutes.marketMovements,
      tone: _FeatureTone.warning,
    ),
    _ExploreFeature(
      title: 'Analytics Dashboard',
      subtitle: 'Performance scorecards, ROI trendline, and daily form.',
      icon: Icons.bar_chart,
      route: AppRoutes.analyticsDashboard,
      tone: _FeatureTone.success,
    ),
    _ExploreFeature(
      title: 'Bet History Analytics',
      subtitle: 'Mistake heatmap and recurring outcome clusters.',
      icon: Icons.history,
      route: AppRoutes.betHistoryAnalytics,
      tone: _FeatureTone.danger,
    ),
    _ExploreFeature(
      title: 'Strategy Builder',
      subtitle: 'Design systems, run simulations, and compare outcomes.',
      icon: Icons.lightbulb_outline,
      route: AppRoutes.strategyBuilder,
      tone: _FeatureTone.warning,
      badge: 'Lab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.exploreGridColumns(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _ExploreHero(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              sliver: SliverGrid.builder(
                itemCount: _features.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: columns == 2 ? 1.02 : 1.2,
                ),
                itemBuilder: (context, index) {
                  final feature = _features[index];
                  return _ExploreFeatureCard(
                    feature: feature,
                    toneColor: _toneColor(context, feature.tone),
                    index: index,
                    onTap: () => AppRoutes.push(context, feature.route),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static void _onNavTap(BuildContext context, int index) {
    if (index == 0) {
      AppRoutes.push(context, AppRoutes.home);
    } else if (index == 2) {
      AppRoutes.push(context, AppRoutes.betting);
    } else if (index == 3) {
      AppRoutes.push(context, AppRoutes.wallet);
    } else if (index == 4) {
      AppRoutes.push(context, AppRoutes.profile);
    }
  }

  static Color _toneColor(BuildContext context, _FeatureTone tone) {
    final scheme = Theme.of(context).colorScheme;

    return switch (tone) {
      _FeatureTone.accent => scheme.accentPrimary,
      _FeatureTone.violet => scheme.accentSecondary,
      _FeatureTone.warning => scheme.warning,
      _FeatureTone.info => scheme.info,
      _FeatureTone.success => scheme.success,
      _FeatureTone.danger => scheme.danger,
    };
  }
}

class _ExploreHero extends StatelessWidget {
  const _ExploreHero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.accentPrimary.withValues(alpha: 0.22),
            scheme.accentSecondary.withValues(alpha: 0.12),
            scheme.backgroundCard,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.accentPrimary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.travel_explore_rounded,
              color: scheme.accentPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Explore Center',
                  variant: AppTextVariant.h1,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  'Sharper tools for smarter bets, live edges, and AI-assisted decisions.',
                  variant: AppTextVariant.body,
                  tone: AppTextTone.secondary,
                ),
                SizedBox(height: AppSpacing.sm),
                AppBadge(
                  label: 'LIVE INSIGHTS',
                  variant: AppBadgeVariant.info,
                  showLiveDot: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.12, end: 0);
  }
}

class _ExploreFeatureCard extends StatelessWidget {
  final _ExploreFeature feature;
  final Color toneColor;
  final int index;
  final VoidCallback onTap;

  const _ExploreFeatureCard({
    required this.feature,
    required this.toneColor,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      elevated: true,
      semanticsLabel: feature.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(feature.icon, color: toneColor, size: 20),
              ),
              const Spacer(),
              if (feature.badge != null)
                AppBadge(
                  label: feature.badge!,
                  variant: feature.badge == 'AI'
                      ? AppBadgeVariant.success
                      : AppBadgeVariant.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            feature.title,
            variant: AppTextVariant.h3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            feature.subtitle,
            variant: AppTextVariant.caption,
            tone: AppTextTone.secondary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              const AppText(
                'Open',
                variant: AppTextVariant.label,
                tone: AppTextTone.info,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.info,
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: (index * 70).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }
}

enum _FeatureTone {
  accent,
  violet,
  warning,
  info,
  success,
  danger,
}

class _ExploreFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final _FeatureTone tone;
  final String? badge;

  const _ExploreFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.tone,
    this.badge,
  });
}
