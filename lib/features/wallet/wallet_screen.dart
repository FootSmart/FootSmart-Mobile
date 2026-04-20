import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';
import '../../core/routes/app_routes.dart';
import '../../core/models/wallet.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/stripe_service.dart';
import '../../core/services/wallet_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/stripe_hosted_setup_page.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const double _usdPerPoint = 4.99 / 500.0;

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
    _bootstrapWallet();
  }

  Future<void> _bootstrapWallet() async {
    await _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final auth = AuthService(ApiService());
    await auth.syncTokenToApi();
    final token = await auth.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _balanceError =
              'Session absente. Connectez-vous pour accéder au portefeuille.';
          _transactionsError = _balanceError;
          _isLoadingBalance = false;
          _isLoadingTransactions = false;
        });
      }
      return;
    }
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

  /// Dépôt via **Stripe Checkout** (Customer) : montant saisi ici, puis cartes enregistrées sur la page Stripe.
  /// Crédit wallet par webhook (`checkout.session.completed` / `payment_intent.succeeded`).
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
      await AuthService(ApiService()).syncTokenToApi();
      final stripe = StripeService(ApiService());
      final checkoutUrl = await stripe.createHostedDepositCheckoutUrl(
        amount: amount,
      );
      if (!mounted) return;

      final sessionId = await Navigator.of(context).push<String?>(
        MaterialPageRoute<String?>(
          builder: (ctx) => StripeHostedSetupPage(
            initialUrl: checkoutUrl,
            returnUrlContains: 'hosted-deposit-return',
            appBarTitle: 'Paiement sécurisé (Stripe)',
          ),
        ),
      );

      if (!mounted) return;
      if (sessionId == null || sessionId.isEmpty) {
        setState(() => _isProcessingDeposit = false);
        return;
      }

      await stripe.completeCheckoutDeposit(sessionId: sessionId);
      await _loadWalletData();

      if (mounted) {
        setState(() => _isProcessingDeposit = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La transaction s’est effectuée avec succès, c’est tout.',
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

  double _usdFromPoints(int points) {
    if (points <= 0) return 0;
    return double.parse((points * _usdPerPoint).toStringAsFixed(2));
  }

  Future<void> _handleWithdrawPoints(int points) async {
    setState(() => _isProcessingWithdraw = true);

    try {
      final result = await _walletService.withdrawPoints(points);
      if (mounted) {
        setState(() => _isProcessingWithdraw = false);

        // Update balance locally
        _balance = WalletBalance(
          balance: result.transaction.newBalance,
          points: result.transaction.newPoints ?? (_balance?.points ?? 0),
          currency: _balance?.currency ?? 'USD',
        );

        // Reload transactions
        await _loadTransactions();

        final usdAmount = _usdFromPoints(points);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully withdrew $points pts (\$${usdAmount.toStringAsFixed(2)})',
              ),
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
    final points = _balance?.points ?? 0;
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
                Row(
                  children: [
                    Text(
                      'Points (for betting)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryDark.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _showPointsHintDialog,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                AppColors.primaryDark.withValues(alpha: 0.35),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '?',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoadingBalance)
                  const CircularProgressIndicator(
                    color: AppColors.primaryDark,
                    strokeWidth: 2,
                  )
                else if (_balanceError != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error loading balance',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _balanceError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryDark.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _loadWalletData,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Réessayer'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ),
                    ],
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
                        TextSpan(text: '$points'),
                        const TextSpan(
                          text: ' pts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  '\$${balanceWhole.toString()}.${balanceDecimal.toString().padLeft(2, '0')} (balance)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark.withValues(alpha: 0.75),
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
        Row(
          children: [
            Text(
              'Transaction History',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showPointsHintDialog,
              icon: const Icon(Icons.help_outline_rounded, size: 18),
              color: context.textSecondary,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              visualDensity: VisualDensity.compact,
              tooltip: 'Points help',
            ),
          ],
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
                if (_transactionsError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _transactionsError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadWalletData,
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

  Future<void> _showPointsHintDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Points Help',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works:',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '- Points are used for bets.\n'
                  '- Bet transactions decrease points.\n'
                  '- Win transactions increase points.\n'
                  '- The amount in history is shown in USD.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: dialogContext.textSecondary),
                ),
                const SizedBox(height: 14),
                Text(
                  'Money per point (from current packs):',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<PointsPack>>(
                  future: _walletService.getPointsPacks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
                      return Text(
                        'Open "Buy Points" to see exact conversion for each pack.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: dialogContext.textSecondary),
                      );
                    }

                    final packs = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: packs.map((pack) {
                        final total = pack.totalPoints <= 0 ? 1 : pack.totalPoints;
                        final perPoint = pack.price / total;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '- ${pack.totalPoints} pts for \$${pack.price.toStringAsFixed(2)} '
                            '(${perPoint.toStringAsFixed(4)} / point)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: dialogContext.textSecondary),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDepositDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availablePoints = _balance?.points ?? 0;
            final requestedPoints =
                int.tryParse(_withdrawController.text.trim()) ?? 0;
            final usdAmount = _usdFromPoints(requestedPoints);

            return AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Buy Points',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: FutureBuilder<List<PointsPack>>(
                  future: _walletService.getPointsPacks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading packs',
                          style: TextStyle(color: AppColors.error),
                        ),
                      );
                    }

                    final packs = snapshot.data ?? [];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: packs.map((pack) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PointsPackCard(
                            pack: pack,
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              await _handleBuyPointsPack(pack.id);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleBuyPointsPack(String packId) async {
    setState(() => _isProcessingDeposit = true);

    try {
      await AuthService(ApiService()).syncTokenToApi();
      final checkoutUrl = await _walletService.buyPointsPack(packId: packId);
      if (!mounted) return;

      final sessionId = await Navigator.of(context).push<String?>(
        MaterialPageRoute<String?>(
          builder: (ctx) => StripeHostedSetupPage(
            initialUrl: checkoutUrl,
            returnUrlContains: 'hosted-deposit-return',
            appBarTitle: 'Paiement sécurisé (Stripe)',
          ),
        ),
      );

      if (!mounted) return;

      if (sessionId == null || sessionId.isEmpty) {
        setState(() => _isProcessingDeposit = false);
        return;
      }

      // Ensure points are credited even if hosted return page couldn't process credit.
      await _walletService.completePointsPackPurchase(sessionId);

      await _loadWalletData();

      setState(() => _isProcessingDeposit = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Points ajoutés avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingDeposit = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showWithdrawDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availablePoints = _balance?.points ?? 0;
            final requestedPoints =
                int.tryParse(_withdrawController.text.trim()) ?? 0;
            final usdAmount = _usdFromPoints(requestedPoints);

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
                            'Available Points',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: const Color(0xFFA0A4B8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$availablePoints pts',
                            style: AppTextStyles.h3
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Auto conversion: 500 pts = \$4.99',
                            style: AppTextStyles.caption
                                .copyWith(color: const Color(0xFFA0A4B8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AmountField(
                      controller: _withdrawController,
                      hintText: 'Points to withdraw',
                      prefixText: 'pts ',
                      decimal: false,
                      onTextChanged: () => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You will receive about \$${usdAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFFA0A4B8)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [100, 250, 500]
                          .map(
                        (amount) => _AmountChip(
                          label: '$amount pts',
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
                                (_balance?.points ?? 0).toString(),
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
                            final points =
                                int.tryParse(_withdrawController.text.trim());
                            final availablePoints = _balance?.points ?? 0;
                            if (points != null && points > 0) {
                              if (points > availablePoints) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Insufficient points for withdrawal'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(dialogContext);
                              await _handleWithdrawPoints(points);
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
                            'Withdraw ${_withdrawController.text.isEmpty ? '0' : _withdrawController.text} pts',
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Converted amount is estimated before confirmation',
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
  const _AmountField({
    required this.controller,
    this.onTextChanged,
    this.hintText = '0.00',
    this.prefixText = '\$ ',
    this.decimal = true,
  });

  final TextEditingController controller;
  final VoidCallback? onTextChanged;
  final String hintText;
  final String prefixText;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onTextChanged?.call(),
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
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

class _PointsPackCard extends StatelessWidget {
  const _PointsPackCard({required this.pack, required this.onTap});

  final PointsPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252B3D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3D4256)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: AppColors.accentGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (pack.bonus > 0)
                    Text(
                      '+${pack.bonus} bonus',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGreen,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '\$${pack.price.toStringAsFixed(2)}',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
