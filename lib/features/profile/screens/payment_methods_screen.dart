import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/models/wallet.dart';
import 'package:footsmart_pro/core/services/api_service.dart'
    show ApiException, ApiService;
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/stripe_service.dart';
import 'package:footsmart_pro/core/services/wallet_service.dart';
import 'package:footsmart_pro/widgets/stripe_hosted_setup_page.dart';
import 'package:intl/intl.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedCard = 0;

  bool _stripeLoading = false;

  List<_CardData> _savedCards = [];
  bool _cardsLoading = true;

  List<WalletTransaction> _walletTransactions = [];
  bool _txLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await AuthService(ApiService()).syncTokenToApi();
    await Future.wait([
      _refreshSavedCards(),
      _refreshWalletTransactions(),
    ]);
  }

  Future<void> _refreshSavedCards() async {
    setState(() => _cardsLoading = true);
    try {
      final stripe = StripeService(ApiService());
      final list = await stripe.fetchPaymentMethods();
      if (!mounted) return;
      setState(() {
        _savedCards = [
          for (var i = 0; i < list.length; i++)
            _CardData.fromStripe(list[i], i),
        ];
        _selectedCard = 0;
      });
    } catch (_) {
      if (mounted) setState(() => _savedCards = []);
    } finally {
      if (mounted) setState(() => _cardsLoading = false);
    }
  }

  Future<void> _refreshWalletTransactions() async {
    setState(() => _txLoading = true);
    try {
      final ws = WalletService(ApiService());
      final res = await ws.getTransactions(limit: 20);
      if (!mounted) return;
      setState(() => _walletTransactions = res.transactions);
    } catch (_) {
      if (mounted) setState(() => _walletTransactions = []);
    } finally {
      if (mounted) setState(() => _txLoading = false);
    }
  }

  bool get _hasStripeCards => _savedCards.isNotEmpty;

  Future<void> _linkStripeCard() async {
    if (_stripeLoading) return;
    setState(() => _stripeLoading = true);
    try {
      await AuthService(ApiService()).syncTokenToApi();
      final stripeService = StripeService(ApiService());
      // Page Stripe Checkout (HTTPS) : la carte est enregistrée sur le même Customer que le Dashboard.
      final checkoutUrl = await stripeService.createHostedSetupCheckoutUrl();
      if (!mounted) return;

      final sessionId = await Navigator.of(context).push<String?>(
        MaterialPageRoute<String?>(
          fullscreenDialog: true,
          builder: (ctx) => StripeHostedSetupPage(initialUrl: checkoutUrl),
        ),
      );

      if (sessionId == null || sessionId.isEmpty) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 600));
      await _refreshSavedCards();
      await _refreshWalletTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carte enregistrée (Stripe).')),
      );
    } catch (e) {
      if (!mounted) return;
      final text = e is ApiException
          ? _stripeUserMessage(e.message)
          : 'Stripe : $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) setState(() => _stripeLoading = false);
    }
  }

  static String _walletTxLabel(WalletTransaction t) {
    switch (t.type) {
      case WalletTransactionType.deposit:
        return 'Dépôt wallet';
      case WalletTransactionType.withdraw:
        return 'Retrait wallet';
      case WalletTransactionType.bet:
        return 'Pari';
      case WalletTransactionType.win:
        return 'Gain';
    }
  }

  static String _stripeUserMessage(String raw) {
    if (raw.contains('Invalid API Key') ||
        raw.contains('clé secrète Stripe') ||
        raw.contains('STRIPE_SECRET_KEY')) {
      return 'Le serveur utilise une clé secrète Stripe refusée (401). '
          'Dans le Dashboard Stripe (mode test) › Développeurs › Clés API, '
          'révélez ou régénérez la clé secrète, collez-la dans STRIPE_SECRET_KEY du fichier .env du backend, '
          'puis redémarrez l’API.';
    }
    return raw;
  }

  static String _formatTxAmount(WalletTransaction t) {
    final sign = t.isPositive ? '+' : '−';
    return '$sign\$${t.amount.abs().toStringAsFixed(2)}';
  }

  static final DateFormat _txDate = DateFormat.yMMMd('fr_FR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Payment Methods',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_rounded, color: AppColors.accentGreen),
            onPressed: _stripeLoading ? null : _linkStripeCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Saved Cards'),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: _cardsLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentGreen,
                      ),
                    )
                  : _savedCards.isEmpty
                      ? const _EmptySavedCardsHint()
                      : PageView.builder(
                          itemCount: _savedCards.length,
                          onPageChanged: (i) =>
                              setState(() => _selectedCard = i),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _CardWidget(card: _savedCards[i]),
                          ),
                        ),
            ),
            const SizedBox(height: 10),
            if (!_cardsLoading && _savedCards.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _savedCards.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _selectedCard ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _selectedCard
                          ? AppColors.accentGreen
                          : const Color(0xFF252B3D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 28),
            _sectionLabel('Stripe'),
            const SizedBox(height: 12),
            _PayMethodTile(
              icon: Icons.credit_card_rounded,
              name: 'Cartes Stripe',
              detail: _stripeLoading
                  ? 'Ouverture…'
                  : (_hasStripeCards
                      ? '${_savedCards.length} carte(s) — appuyer pour en ajouter'
                      : 'Ajouter une carte'),
              isLinked: _hasStripeCards,
              onTap: _stripeLoading ? null : _linkStripeCard,
            ),
            const SizedBox(height: 28),
            _sectionLabel('Recent Transactions'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF252B3D)),
              ),
              child: _txLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    )
                  : _walletTransactions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24),
                          child: Center(
                            child: Text(
                              'Aucune transaction wallet pour le moment.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFFA0A4B8),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0;
                                i < _walletTransactions.length;
                                i++) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _walletTransactions[i]
                                                .isPositive
                                            ? const Color(0x3300FF88)
                                            : const Color(0x33FF7A00),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _walletTransactions[i].isPositive
                                            ? Icons.south_west_rounded
                                            : Icons.north_east_rounded,
                                        size: 16,
                                        color: _walletTransactions[i]
                                                .isPositive
                                            ? AppColors.accentGreen
                                            : AppColors.accentOrange,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _walletTxLabel(
                                                _walletTransactions[i]),
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _txDate.format(
                                              _walletTransactions[i]
                                                  .createdAt
                                                  .toLocal(),
                                            ),
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: const Color(0xFFA0A4B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatTxAmount(
                                          _walletTransactions[i]),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _walletTransactions[i]
                                                .isPositive
                                            ? AppColors.accentGreen
                                            : AppColors.textWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i < _walletTransactions.length - 1)
                                const Divider(
                                  color: Color(0xFF252B3D),
                                  height: 1,
                                  indent: 56,
                                ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
            color: const Color(0xFFA0A4B8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );
}

class _EmptySavedCardsHint extends StatelessWidget {
  const _EmptySavedCardsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off_rounded,
            color: AppColors.accentGreen.withValues(alpha: 0.75),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune carte enregistrée',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez une carte via Stripe ci-dessous',
            style: AppTextStyles.caption.copyWith(color: const Color(0xFFA0A4B8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  const _CardWidget({required this.card});
  final _CardData card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [card.color1, card.color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.brand,
                  style: AppTextStyles.h4
                      .copyWith(fontWeight: FontWeight.bold)),
              if (card.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x3300FF88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Default',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const Spacer(),
          Text('•••• •••• •••• ${card.last4}',
              style: AppTextStyles.h3
                  .copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CARD HOLDER',
                    style: AppTextStyles.overline
                        .copyWith(color: const Color(0xFFA0A4B8))),
                Text(card.holder,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 24),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('EXPIRES',
                    style: AppTextStyles.overline
                        .copyWith(color: const Color(0xFFA0A4B8))),
                Text(card.expiry,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  const _PayMethodTile({
    required this.icon,
    required this.name,
    required this.detail,
    required this.isLinked,
    this.onTap,
  });

  final IconData icon;
  final String name;
  final String detail;
  final bool isLinked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF252B3D)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF252B3D),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: AppColors.accentGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(detail,
                      style: AppTextStyles.caption
                          .copyWith(color: const Color(0xFFA0A4B8))),
                ],
              ),
            ),
            if (isLinked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x3300FF88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Linked',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600)),
              )
            else
              const Icon(Icons.add_rounded,
                  color: Color(0xFFA0A4B8), size: 20),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  const _CardData({
    required this.last4,
    required this.brand,
    required this.expiry,
    required this.holder,
    required this.isDefault,
    required this.color1,
    required this.color2,
  });

  static const List<(Color, Color)> _gradientPairs = [
    (Color(0xFF1A3A4A), Color(0xFF0D2233)),
    (Color(0xFF3A1A1A), Color(0xFF2A0D0D)),
    (Color(0xFF1A2A3A), Color(0xFF0D1A2A)),
    (Color(0xFF2A1A3A), Color(0xFF1A0D2A)),
  ];

  factory _CardData.fromStripe(Map<String, dynamic> json, int index) {
    final expM = json['expMonth'];
    final expY = json['expYear'];
    var expiry = '— / —';
    if (expM != null && expY != null) {
      final m = expM.toString().padLeft(2, '0');
      final yStr = expY.toString();
      final y = yStr.length >= 2 ? yStr.substring(yStr.length - 2) : yStr;
      expiry = '$m / $y';
    }
    final holderRaw = json['holder'] as String?;
    final holder = (holderRaw != null && holderRaw.trim().isNotEmpty)
        ? holderRaw.trim()
        : 'Card holder';
    final g = _gradientPairs[index % _gradientPairs.length];
    return _CardData(
      last4: json['last4'] as String? ?? '----',
      brand: json['brand'] as String? ?? 'Card',
      expiry: expiry,
      holder: holder,
      isDefault: json['isDefault'] == true,
      color1: g.$1,
      color2: g.$2,
    );
  }

  final String last4;
  final String brand;
  final String expiry;
  final String holder;
  final bool isDefault;
  final Color color1;
  final Color color2;
}
