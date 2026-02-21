import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/widgets/bottom_nav_bar.dart';
import '../../core/extensions/theme_context.dart';

class BettingScreen extends StatefulWidget {
  const BettingScreen({super.key});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  String selectedBetType = 'Match Result';
  String selectedOutcome = 'Man City Win';
  double selectedOdds = 2.1;
  int stakeAmount = 10;

  final List<String> betTypes = [
    'Match Result',
    'Over/Under',
    'Both Teams to Score'
  ];

  final List<BetOption> matchResultOptions = [
    BetOption(label: 'Man City Win', odds: 2.1, isSelected: true),
    BetOption(label: 'Draw', odds: 3.4, isSelected: false),
    BetOption(label: 'Liverpool Win', odds: 3.8, isSelected: false),
  ];

  final List<int> quickStakeAmounts = [5, 10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
        title: Text(
          'Place Bet',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bet Type Tabs
                    _buildBetTypeTabs(),
                    const SizedBox(height: 24),

                    // Bet Options
                    _buildBetOptions(),
                    const SizedBox(height: 32),

                    // Stake Amount Section
                    _buildStakeSection(),
                    const SizedBox(height: 24),

                    // Bet Summary
                    _buildBetSummary(),
                    const SizedBox(height: 24),

                    // Warning Message
                    _buildWarningMessage(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Confirm Button
          _buildConfirmButton(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, AppRoutes.home);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.explore);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.wallet);
          } else if (index == 4) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildBetTypeTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: betTypes.map((type) {
          final isSelected = type == selectedBetType;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBetType = type;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? context.accent : context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? context.accent : context.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? context.surfaceBg : context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBetOptions() {
    return Column(
      children: matchResultOptions.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                for (var opt in matchResultOptions) {
                  opt.isSelected = false;
                }
                option.isSelected = true;
                selectedOutcome = option.label;
                selectedOdds = option.odds;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      option.isSelected ? context.accent : context.borderSubtle,
                  width: option.isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        option.odds.toString(),
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (option.isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: context.surfaceBg,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStakeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stake Amount',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Amount Input with +/- buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (stakeAmount > 5) stakeAmount -= 5;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.surfaceBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: context.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stakeAmount.toString(),
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    stakeAmount += 5;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.surfaceBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: context.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Stake Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: quickStakeAmounts.map((amount) {
            final isSelected = amount == stakeAmount;
            return GestureDetector(
              onTap: () {
                setState(() {
                  stakeAmount = amount;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.accent.withValues(alpha: 0.2)
                      : context.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? context.accent : context.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Text(
                  '\$$amount',
                  style: TextStyle(
                    color: isSelected ? context.accent : context.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBetSummary() {
    final potentialWin = (stakeAmount * selectedOdds).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stake',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '\$$stakeAmount',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Odds',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                selectedOdds.toString(),
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.borderSubtle, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Potential Win',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$$potentialWin',
                style: TextStyle(
                  color: context.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF8A65).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF8A65),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Remember to bet responsibly. Only bet what you can afford to lose.',
              style: TextStyle(
                color: Color(0xFFFF8A65),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: context.surfaceBg,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Confirm Bet - \$$stakeAmount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.elevatedBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Bet',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to place a bet:',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Outcome', selectedOutcome),
            _buildDetailRow('Odds', selectedOdds.toString()),
            _buildDetailRow('Stake', '\$$stakeAmount'),
            Divider(color: context.borderSubtle, height: 24),
            _buildDetailRow(
              'Potential Win',
              '\$${(stakeAmount * selectedOdds).toStringAsFixed(2)}',
              isHighlight: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSuccessMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: context.surfaceBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Place Bet'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlight ? context.textPrimary : context.textSecondary,
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? context.accent : context.textPrimary,
              fontSize: isHighlight ? 18 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bet placed successfully!'),
        backgroundColor: context.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Model class for bet options
class BetOption {
  final String label;
  final double odds;
  bool isSelected;

  BetOption({
    required this.label,
    required this.odds,
    this.isSelected = false,
  });
}
