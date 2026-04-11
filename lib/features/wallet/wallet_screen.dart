import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';
import '../../core/routes/app_routes.dart';
import '../../core/models/wallet.dart';
import '../../core/services/api_service.dart';
import '../../core/services/stripe_service.dart';
import '../../core/services/wallet_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final WalletService _walletService;
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();

  WalletBalance? _balance;
  List<WalletTransaction> _transactions = [];

  bool _isLoadingBalance = true;
  bool _isLoadingTransactions = true;
  bool _isProcessingDeposit = false;
  bool _isProcessingWithdraw = false;

  String? _balanceError;
  String? _transactionsError;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService(ApiService());
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    await Future.wait([
      _loadBalance(),
      _loadTransactions(),
    ]);
  }

  Future<void> _loadBalance() async {
    setState(() {
      _isLoadingBalance = true;
      _balanceError = null;
    });

    try {
      final balance = await _walletService.getBalance();
      if (mounted) {
        setState(() {
          _balance = balance;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _balanceError = e.toString();
          _isLoadingBalance = false;
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
      _transactionsError = null;
    });

    try {
      final response = await _walletService.getTransactions(limit: 50);
      if (mounted) {
        setState(() {
          _transactions = response.transactions;
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transactionsError = e.toString();
          _isLoadingTransactions = false;
        });
      }
    }
  }

  /// Dépôt réel via Stripe (PaymentIntent) — le crédit wallet est fait côté serveur par webhook.
  Future<void> _handleDeposit(double amount) async {
    if (amount < 0.5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Montant minimum 0,50 \$ (exigence Stripe).',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessingDeposit = true);

    try {
      final stripe = StripeService(ApiService());
      final completed = await stripe.depositWithPaymentSheet(amount: amount);
      if (!mounted) return;
      if (!completed) {
        setState(() => _isProcessingDeposit = false);
        return;
      }

      // Le webhook `payment_intent.succeeded` crédite le wallet (quelques secondes max).
      await Future<void>.delayed(const Duration(seconds: 2));
      await _loadWalletData();
      await Future<void>.delayed(const Duration(seconds: 2));
      await _loadWalletData();

      if (mounted) {
        setState(() => _isProcessingDeposit = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paiement Stripe réussi — solde mis à jour (vérifie aussi Stripe Dashboard › Paiements).',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingDeposit = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dépôt Stripe : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleWithdraw(double amount) async {
    setState(() => _isProcessingWithdraw = true);

    try {
      final result = await _walletService.withdraw(amount);
      if (mounted) {
        setState(() => _isProcessingWithdraw = false);

        // Update balance locally
        _balance = WalletBalance(
          balance: result.transaction.newBalance,
          currency: _balance?.currency ?? 'USD',
        );

        // Reload transactions
        await _loadTransactions();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Successfully withdrew \$${amount.toStringAsFixed(2)}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingWithdraw = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _depositController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: _isLoadingBalance && _isLoadingTransactions
            ? Center(
                child: CircularProgressIndicator(color: context.accent),
              )
            : RefreshIndicator(
                onRefresh: _loadWalletData,
                color: context.accent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            const SizedBox(height: 24),
                            _buildTransactionSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, AppRoutes.home);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.explore);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.betting);
          } else if (index == 4) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    final balance = _balance?.balance ?? 0.0;
    final balanceWhole = balance.floor();
    final balanceDecimal = ((balance - balanceWhole) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.cardBg.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.accent,
                  context.accent.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryDark.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoadingBalance)
                  const CircularProgressIndicator(
                    color: AppColors.primaryDark,
                    strokeWidth: 2,
                  )
                else if (_balanceError != null)
                  Text(
                    'Error loading balance',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  )
                else
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(text: '\$$balanceWhole'),
                        TextSpan(
                          text: '.${balanceDecimal.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoadingBalance ? null : _showDepositDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
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
                        onPressed:
                            _isLoadingBalance ? null : _showWithdrawDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(
                            color: AppColors.primaryDark,
                            width: 2,
                          ),
                          backgroundColor:
                              AppColors.primaryDark.withValues(alpha: 0.2),
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
        ],
      ),
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
        if (_isLoadingTransactions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_transactionsError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Error loading transactions',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadTransactions,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (_transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF252B3D)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: context.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                                () =>
                                    _depositController.text = amount.toString(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Le montant sera débité via Stripe (visible dans Dashboard › Paiements, mode test).',
                      style: AppTextStyles.caption
                          .copyWith(color: const Color(0xFFA0A4B8)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Method',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFFA0A4B8)),
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
                          Text('Credit/Debit Card',
                              style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Instant deposit',
                            style: AppTextStyles.caption
                                .copyWith(color: const Color(0xFFA0A4B8)),
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
                    onPressed: _isProcessingDeposit
                        ? null
                        : () async {
                            final amount =
                                double.tryParse(_depositController.text);
                            if (amount != null && amount > 0) {
                              Navigator.pop(dialogContext);
                              await _handleDeposit(amount);
                              _depositController.clear();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B1220),
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: _isProcessingDeposit
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0B1220),
                            ),
                          )
                        : Text(
                            'Deposit \$${_depositController.text.isEmpty ? '0' : _depositController.text}'),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                            style: AppTextStyles.bodySmall
                                .copyWith(color: const Color(0xFFA0A4B8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${(_balance?.balance ?? 0.0).toStringAsFixed(2)}',
                            style: AppTextStyles.h3
                                .copyWith(fontWeight: FontWeight.bold),
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
                            () => _withdrawController.text =
                                (_balance?.balance ?? 0.0).toStringAsFixed(2),
                          ),
                        ),
                      ]).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessingWithdraw
                        ? null
                        : () async {
                            final amount =
                                double.tryParse(_withdrawController.text);
                            if (amount != null && amount > 0) {
                              Navigator.pop(dialogContext);
                              await _handleWithdraw(amount);
                              _withdrawController.clear();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B1220),
                      backgroundColor: AppColors.accentGreen,
                    ),
                    child: _isProcessingWithdraw
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0B1220),
                            ),
                          )
                        : Text(
                            'Withdraw \$${_withdrawController.text.isEmpty ? '0' : _withdrawController.text}',
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Withdrawals are processed within 1-3 business days',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFFA0A4B8)),
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

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == WalletTransactionType.deposit;
    final isWithdraw = transaction.type == WalletTransactionType.withdraw;
    final isWin = transaction.type == WalletTransactionType.win;

    Color iconBackground = const Color(0x33A0A4B8);
    Color iconColor = const Color(0xFFA0A4B8);
    IconData iconData = Icons.schedule_rounded;
    String typeLabel = 'Transaction';

    if (isDeposit) {
      iconBackground = const Color(0x3300FF88);
      iconColor = AppColors.accentGreen;
      iconData = Icons.south_west_rounded;
      typeLabel = 'Deposit';
    } else if (isWithdraw) {
      iconBackground = const Color(0x33FF7A00);
      iconColor = AppColors.accentOrange;
      iconData = Icons.north_east_rounded;
      typeLabel = 'Withdrawal';
    } else if (isWin) {
      iconBackground = const Color(0x3300FF88);
      iconColor = AppColors.accentGreen;
      iconData = Icons.celebration_rounded;
      typeLabel = 'Win';
    } else {
      iconBackground = const Color(0x33FFD700);
      iconColor = const Color(0xFFFFD700);
      iconData = Icons.sports_soccer_rounded;
      typeLabel = 'Bet';
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final formattedDate = dateFormat.format(transaction.createdAt);
    final formattedTime = timeFormat.format(transaction.createdAt);

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
            decoration:
                BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$formattedDate • $formattedTime',
                  style: AppTextStyles.caption
                      .copyWith(color: const Color(0xFFA0A4B8)),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isPositive ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: transaction.isPositive
                  ? AppColors.accentGreen
                  : AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
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
        hintStyle:
            AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF606060)),
        filled: true,
        fillColor: const Color(0xFF0B1220),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
