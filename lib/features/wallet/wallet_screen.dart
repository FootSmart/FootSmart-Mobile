import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/routes/bottom_nav_handler.dart';
import 'package:footsmart_pro/widgets/bottom_nav_bar.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();

  static const double _balance = 287.50;

  static const List<_Transaction> _transactions = [
    _Transaction(
      id: 1,
      type: TransactionType.deposit,
      amount: 100.0,
      status: TransactionStatus.completed,
      date: '2026-02-13 14:32',
      method: 'Credit Card',
    ),
    _Transaction(
      id: 2,
      type: TransactionType.bet,
      amount: -25.0,
      status: TransactionStatus.settled,
      date: '2026-02-13 13:15',
      match: 'Man City vs Liverpool',
      result: BetResult.won,
      payout: 52.50,
    ),
    _Transaction(
      id: 3,
      type: TransactionType.withdraw,
      amount: -50.0,
      status: TransactionStatus.pending,
      date: '2026-02-12 18:45',
      method: 'Bank Transfer',
    ),
    _Transaction(
      id: 4,
      type: TransactionType.bet,
      amount: -15.0,
      status: TransactionStatus.settled,
      date: '2026-02-12 16:20',
      match: 'Barcelona vs Real Madrid',
      result: BetResult.lost,
    ),
    _Transaction(
      id: 5,
      type: TransactionType.deposit,
      amount: 200.0,
      status: TransactionStatus.completed,
      date: '2026-02-11 10:15',
      method: 'PayPal',
    ),
  ];

  static const List<_PendingBet> _pendingBets = [
    _PendingBet(
      id: 1,
      match: 'Bayern vs Dortmund',
      bet: 'Bayern Win',
      stake: 20.0,
      odds: 1.85,
      potentialWin: 37.0,
      time: 'Tomorrow, 18:30',
    ),
    _PendingBet(
      id: 2,
      match: 'PSG vs Marseille',
      bet: 'Over 2.5 Goals',
      stake: 15.0,
      odds: 1.95,
      potentialWin: 29.25,
      time: 'Tomorrow, 20:00',
    ),
  ];

  @override
  void dispose() {
    _depositController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPendingBetsSection(),
                    const SizedBox(height: 24),
                    _buildTransactionSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          handleBottomNavTap(context, currentIndex: 3, index: index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F2E), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00FF88), Color(0xFF00CC6E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF0B1220).withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.h1.copyWith(
                      color: const Color(0xFF0B1220),
                      fontSize: 44,
                    ),
                    children: const [
                      TextSpan(text: '\$287'),
                      TextSpan(
                        text: '.50',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showDepositDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1220),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Deposit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showWithdrawDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B1220),
                          side: const BorderSide(color: Color(0xFF0B1220), width: 2),
                          backgroundColor: const Color(0x330B1220),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.north_east_rounded, size: 20),
                        label: const Text('Withdraw'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _QuickStatCard(
                  label: 'Weekly Wagered',
                  value: '\$125',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  label: 'Weekly Won',
                  value: '\$89.75',
                  valueColor: AppColors.accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule_rounded, color: AppColors.accentOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pending Bets',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_pendingBets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration,
            child: Text(
              'No pending bets',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFFA0A4B8)),
            ),
          )
        else
          Column(
            children: _pendingBets
                .map(
                  (bet) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PendingBetCard(bet: bet),
              ),
            )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(
          children: _transactions
              .map(
                (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TransactionCard(transaction: transaction),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _showDepositDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Deposit Funds',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AmountField(controller: _depositController),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [25, 50, 100, 200]
                          .map(
                            (amount) => _AmountChip(
                          label: '\$$amount',
                          onTap: () => setModalState(
                                () => _depositController.text = amount.toString(),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Method',
                      style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFA0A4B8)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252B3D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credit/Debit Card', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Instant deposit',
                            style: AppTextStyles.caption.copyWith(color: const Color(0xFFA0A4B8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _depositController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B1220),
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: Text('Deposit \$${_depositController.text.isEmpty ? '0' : _depositController.text}'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showWithdrawDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Withdraw Funds',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFA0A4B8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${_balance.toStringAsFixed(2)}',
                            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AmountField(controller: _withdrawController),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [50, 100, 200]
                          .map(
                            (amount) => _AmountChip(
                          label: '\$$amount',
                          onTap: () => setModalState(
                                () => _withdrawController.text = amount.toString(),
                          ),
                        ),
                      )
                          .followedBy([
                        _AmountChip(
                          label: 'All',
                          onTap: () => setModalState(
                                () => _withdrawController.text = _balance.toStringAsFixed(2),
                          ),
                        ),
                      ])
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _withdrawController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B1220),
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: Text(
                      'Withdraw \$${_withdrawController.text.isEmpty ? '0' : _withdrawController.text}',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Withdrawals are processed within 1-3 business days',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: const Color(0xFFA0A4B8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Color(0xFF1A1F2E),
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xFF252B3D))),
  );
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFF252B3D))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFA0A4B8)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _PendingBetCard extends StatelessWidget {
  const _PendingBetCard({required this.bet});

  final _PendingBet bet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFF252B3D))),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bet.match,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bet.bet,
                      style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFA0A4B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bet.time,
                      style: AppTextStyles.caption.copyWith(color: const Color(0xFFA0A4B8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33FF7A00),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'PENDING',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.accentOrange,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF252B3D), height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _BetMetric(label: 'Stake', value: '\$${bet.stake}'),
              _BetMetric(label: 'Odds', value: '${bet.odds}'),
              _BetMetric(label: 'To Win', value: '\$${bet.potentialWin}', color: AppColors.accentGreen),
            ],
          ),
        ],
      ),
    );
  }
}

class _BetMetric extends StatelessWidget {
  const _BetMetric({required this.label, required this.value, this.color = Colors.white});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: const Color(0xFFA0A4B8))),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final _Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final isWithdraw = transaction.type == TransactionType.withdraw;
    final isBet = transaction.type == TransactionType.bet;

    Color iconBackground = const Color(0x33A0A4B8);
    Color iconColor = const Color(0xFFA0A4B8);
    IconData iconData = Icons.schedule_rounded;

    if (isDeposit) {
      iconBackground = const Color(0x3300FF88);
      iconColor = AppColors.accentGreen;
      iconData = Icons.south_west_rounded;
    } else if (isWithdraw) {
      iconBackground = const Color(0x33FF7A00);
      iconColor = AppColors.accentOrange;
      iconData = Icons.north_east_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFF252B3D))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit
                      ? 'Deposit'
                      : isWithdraw
                      ? 'Withdrawal'
                      : (transaction.match ?? 'Bet'),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.date}${transaction.method == null ? '' : ' • ${transaction.method}'}',
                  style: AppTextStyles.caption.copyWith(color: const Color(0xFFA0A4B8)),
                ),
                if (isBet && transaction.result != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      transaction.result == BetResult.won
                          ? 'Won \$${transaction.payout?.toStringAsFixed(2) ?? '0'}'
                          : 'Lost',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: transaction.result == BetResult.won
                            ? AppColors.accentGreen
                            : const Color(0xFFF87171),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount > 0 ? '+' : ''}\$${transaction.amount.abs()}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: transaction.amount > 0 ? AppColors.accentGreen : AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (transaction.status == TransactionStatus.pending)
                Text(
                  'Pending',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accentOrange),
                ),
              if (transaction.status == TransactionStatus.completed)
                const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: '0.00',
        prefixText: '\$ ',
        prefixStyle: AppTextStyles.h4.copyWith(color: AppColors.accentGreen),
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF606060)),
        filled: true,
        fillColor: const Color(0xFF0B1220),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF252B3D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF252B3D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PendingBet {
  const _PendingBet({
    required this.id,
    required this.match,
    required this.bet,
    required this.stake,
    required this.odds,
    required this.potentialWin,
    required this.time,
  });

  final int id;
  final String match;
  final String bet;
  final double stake;
  final double odds;
  final double potentialWin;
  final String time;
}

enum TransactionType { deposit, withdraw, bet }

enum TransactionStatus { pending, completed, settled }

enum BetResult { won, lost }

class _Transaction {
  const _Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    this.method,
    this.match,
    this.result,
    this.payout,
  });

  final int id;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final String date;
  final String? method;
  final String? match;
  final BetResult? result;
  final double? payout;
}
