import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/bottom_nav_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
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
                          'Welcome back,',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'John Doe',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textWhite,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.cardBackground,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Risk Meter Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.speed_rounded,
                                color: AppColors.accentGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Risk Meter',
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Moderate',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.borderDark,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.borderDark,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You've placed 5 bets this week (Limit: 10)",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Featured Matches Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Matches',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Match Card 1
                _MatchCard(
                  league: 'Premier League',
                  riskLevel: 'Medium Risk',
                  riskColor: AppColors.warning,
                  team1: 'Manchester\nCity',
                  team2: 'Liverpool',
                  homeOdds: '2.1',
                  drawOdds: '3.4',
                  awayOdds: '3.8',
                  aiConfidence: '87%',
                ),

                const SizedBox(height: 16),

                // Match Card 2
                _MatchCard(
                  league: 'La Liga',
                  riskLevel: 'Low Risk',
                  riskColor: AppColors.success,
                  team1: 'Barcelona',
                  team2: 'Real Madrid',
                  homeOdds: '2.5',
                  drawOdds: '3.2',
                  awayOdds: '2.9',
                  aiConfidence: '92%',
                ),

                const SizedBox(height: 24),

                // Trending Bets Section
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.accentOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trending Bets',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Trending Bet 1
                _TrendingBetCard(
                  betTitle: 'Over 2.5 Goals',
                  match: 'Man City vs Liverpool',
                  percentage: '78%',
                  backingText: 'backing this',
                ),

                const SizedBox(height: 12),

                // Trending Bet 2
                _TrendingBetCard(
                  betTitle: 'Barcelona Win',
                  match: 'Barcelona vs Real Madrid',
                  percentage: '64%',
                  backingText: 'backing this',
                ),

                const SizedBox(height: 12),

                // Trending Bet 3
                _TrendingBetCard(
                  betTitle: 'BTTS Yes',
                  match: 'Bayern vs Dortmund',
                  percentage: '71%',
                  backingText: 'backing this',
                ),

                const SizedBox(height: 24),

                // Top Predictors Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Predictors',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Predictor 1
                _PredictorCard(
                  rank: '1',
                  rankColor: const Color(0xFFFFD700),
                  username: 'BetMaster_99',
                  wins: '142 wins',
                  accuracy: '94%',
                ),

                const SizedBox(height: 12),

                // Predictor 2
                _PredictorCard(
                  rank: '2',
                  rankColor: const Color(0xFF808080),
                  username: 'FootballPro',
                  wins: '138 wins',
                  accuracy: '91%',
                ),

                const SizedBox(height: 12),

                // Predictor 3
                _PredictorCard(
                  rank: '3',
                  rankColor: const Color(0xFFCD7F32),
                  username: 'StatKing',
                  wins: '135 wins',
                  accuracy: '89%',
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          handleBottomNavTap(context, currentIndex: 0, index: index);
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String league;
  final String riskLevel;
  final Color riskColor;
  final String team1;
  final String team2;
  final String homeOdds;
  final String drawOdds;
  final String awayOdds;
  final String aiConfidence;

  const _MatchCard({
    required this.league,
    required this.riskLevel,
    required this.riskColor,
    required this.team1,
    required this.team2,
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
    required this.aiConfidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // League and Risk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                league,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  riskLevel,
                  style: AppTextStyles.caption.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Teams
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  team1,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  team2,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Odds
          Row(
            children: [
              Expanded(
                child: _OddsButton(
                  label: 'Home',
                  odds: homeOdds,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OddsButton(
                  label: 'Draw',
                  odds: drawOdds,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OddsButton(
                  label: 'Away',
                  odds: awayOdds,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AI Confidence
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: AppColors.accentGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI Confidence',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      aiConfidence,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.accentGreen,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OddsButton extends StatelessWidget {
  final String label;
  final String odds;

  const _OddsButton({
    required this.label,
    required this.odds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            odds,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingBetCard extends StatelessWidget {
  final String betTitle;
  final String match;
  final String percentage;
  final String backingText;

  const _TrendingBetCard({
    required this.betTitle,
    required this.match,
    required this.percentage,
    required this.backingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  betTitle,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                backingText,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textGrey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PredictorCard extends StatelessWidget {
  final String rank;
  final Color rankColor;
  final String username;
  final String wins;
  final String accuracy;

  const _PredictorCard({
    required this.rank,
    required this.rankColor,
    required this.username,
    required this.wins,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wins,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                accuracy,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'accuracy',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textGrey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
