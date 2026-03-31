import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedCard = 0;

  static const List<_CardData> _cards = [
    _CardData(
      last4: '4242',
      brand: 'Visa',
      expiry: '09 / 28',
      holder: 'John Doe',
      isDefault: true,
      color1: Color(0xFF1A3A4A),
      color2: Color(0xFF0D2233),
    ),
    _CardData(
      last4: '1881',
      brand: 'Mastercard',
      expiry: '03 / 27',
      holder: 'John Doe',
      isDefault: false,
      color1: Color(0xFF3A1A1A),
      color2: Color(0xFF2A0D0D),
    ),
  ];

  static const List<_TxRow> _recent = [
    _TxRow(method: 'Visa •••• 4242', amount: '+\$100.00',
        date: 'Feb 13, 2026', isCredit: true),
    _TxRow(method: 'Visa •••• 4242', amount: '-\$50.00',
        date: 'Feb 12, 2026', isCredit: false),
    _TxRow(method: 'PayPal', amount: '+\$200.00',
        date: 'Feb 11, 2026', isCredit: true),
    _TxRow(method: 'Mastercard •••• 1881', amount: '-\$75.00',
        date: 'Feb 8, 2026', isCredit: false),
  ];

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
            onPressed: _showAddCardSheet,
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
              child: PageView.builder(
                itemCount: _cards.length,
                onPageChanged: (i) => setState(() => _selectedCard = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _CardWidget(card: _cards[i]),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _cards.length,
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
            _sectionLabel('Other Methods'),
            const SizedBox(height: 12),
            _PayMethodTile(
              icon: Icons.paypal_rounded,
              name: 'PayPal',
              detail: 'john@paypal.com',
              isLinked: true,
            ),
            const SizedBox(height: 10),
            _PayMethodTile(
              icon: Icons.account_balance_outlined,
              name: 'Bank Transfer',
              detail: 'Add your bank account',
              isLinked: false,
            ),
            const SizedBox(height: 10),
            _PayMethodTile(
              icon: Icons.currency_bitcoin_rounded,
              name: 'Crypto',
              detail: 'BTC / ETH / USDT',
              isLinked: false,
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
              child: Column(
                children: [
                  for (int i = 0; i < _recent.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _recent[i].isCredit
                                  ? const Color(0x3300FF88)
                                  : const Color(0x33FF7A00),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _recent[i].isCredit
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded,
                              size: 16,
                              color: _recent[i].isCredit
                                  ? AppColors.accentGreen
                                  : AppColors.accentOrange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_recent[i].method,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600)),
                                Text(_recent[i].date,
                                    style: AppTextStyles.caption.copyWith(
                                        color: const Color(0xFFA0A4B8))),
                              ],
                            ),
                          ),
                          Text(
                            _recent[i].amount,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _recent[i].isCredit
                                  ? AppColors.accentGreen
                                  : AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _recent.length - 1)
                      const Divider(
                          color: Color(0xFF252B3D), height: 1, indent: 56),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF252B3D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Add New Card',
                style: AppTextStyles.h4
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _sheetField('Card Number', '1234 5678 9012 3456'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _sheetField('Expiry', 'MM / YY')),
              const SizedBox(width: 12),
              Expanded(child: _sheetField('CVV', '•••')),
            ]),
            const SizedBox(height: 12),
            _sheetField('Card Holder Name', 'John Doe'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: const Color(0xFF0B1220),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save Card',
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: const Color(0xFF0B1220),
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sheetField(String label, String hint) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFFA0A4B8))),
          const SizedBox(height: 6),
          TextField(
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: const Color(0xFF606060)),
              filled: true,
              fillColor: const Color(0xFF252B3D),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF252B3D)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF252B3D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.accentGreen),
              ),
            ),
          ),
        ],
      );

  static Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
            color: const Color(0xFFA0A4B8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );
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
  });

  final IconData icon;
  final String name;
  final String detail;
  final bool isLinked;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child:
                Icon(icon, size: 20, color: AppColors.accentGreen),
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

  final String last4;
  final String brand;
  final String expiry;
  final String holder;
  final bool isDefault;
  final Color color1;
  final Color color2;
}

class _TxRow {
  const _TxRow({
    required this.method,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  final String method;
  final String amount;
  final String date;
  final bool isCredit;
}

