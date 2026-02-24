import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchCtrl = TextEditingController();
  int? _expandedFaq;

  static const List<_Faq> _faqs = [
    _Faq(
      q: 'How do I deposit funds?',
      a: 'Go to Wallet → Deposit. Choose your payment method (credit card, PayPal, bank transfer), enter an amount, and confirm. Deposits are usually instant.',
    ),
    _Faq(
      q: 'How long does a withdrawal take?',
      a: 'Card withdrawals take 1–3 business days. Bank transfers may take up to 5 business days. PayPal is usually processed within 24 hours.',
    ),
    _Faq(
      q: 'How do I verify my identity (KYC)?',
      a: 'Go to Profile → Verification Status. You\'ll need to upload a government-issued ID and proof of address. Approval typically takes 24–48 hours.',
    ),
    _Faq(
      q: 'What happens if I forget my password?',
      a: 'On the Sign-In screen tap "Forgot Password". Enter your email and we\'ll send you a reset link.',
    ),
    _Faq(
      q: 'How do I set deposit or betting limits?',
      a: 'Go to Profile → Responsible Gambling. You can set daily, weekly, and monthly deposit limits, or activate cooling-off periods.',
    ),
    _Faq(
      q: 'Can I cancel a bet after placing it?',
      a: 'Bets can only be cancelled within 5 minutes of placement and only if the market has not yet moved. Tap the bet in Betting History to see the cancel option.',
    ),
    _Faq(
      q: 'Why was my withdrawal declined?',
      a: 'Withdrawals may be declined if your account is not fully verified, you have a pending bonus wagering requirement, or your payment method requires verification.',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Faq> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _faqs;
    return _faqs
        .where((f) =>
            f.q.toLowerCase().contains(q) || f.a.toLowerCase().contains(q))
        .toList();
  }

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
        title: Text('Help & Support',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact cards
            Row(children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Live Chat',
                  subtitle: 'Avg. 2 min',
                  color: AppColors.accentGreen,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email Us',
                  subtitle: 'support@\nfootsmart.pro',
                  color: const Color(0xFF4A90E2),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '+1 800 0100',
                  color: AppColors.accentOrange,
                  onTap: () {},
                ),
              ),
            ]),
            const SizedBox(height: 28),
            _sectionLabel('Quick Topics'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Deposits',
                'Withdrawals',
                'Verification',
                'Bets',
                'Account',
                'Bonuses',
                'Security',
                'Technical',
              ]
                  .map((t) => GestureDetector(
                        onTap: () {
                          setState(() => _searchCtrl.text = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1F2E),
                            borderRadius: BorderRadius.circular(999),
                            border:
                                Border.all(color: const Color(0xFF252B3D)),
                          ),
                          child: Text(t,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 28),
            _sectionLabel('FAQ'),
            const SizedBox(height: 12),
            // Search
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search questions…',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: const Color(0xFF606060)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFFA0A4B8)),
                filled: true,
                fillColor: const Color(0xFF1A1F2E),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF252B3D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF252B3D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accentGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF252B3D)),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _filtered.length; i++) ...[
                    _FaqTile(
                      faq: _filtered[i],
                      index: i,
                      expanded: _expandedFaq == i,
                      onTap: () => setState(() =>
                          _expandedFaq = _expandedFaq == i ? null : i),
                    ),
                    if (i < _filtered.length - 1)
                      const Divider(
                          color: Color(0xFF252B3D), height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Ticket history
            _sectionLabel('Your Tickets'),
            const SizedBox(height: 12),
            _TicketCard(
              id: '#TK-00421',
              subject: 'Withdrawal delay',
              status: 'Resolved',
              date: 'Feb 10, 2026',
              statusColor: AppColors.accentGreen,
            ),
            const SizedBox(height: 10),
            _TicketCard(
              id: '#TK-00387',
              subject: 'KYC document query',
              status: 'Closed',
              date: 'Jan 28, 2026',
              statusColor: const Color(0xFFA0A4B8),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF252B3D)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption
                    .copyWith(color: const Color(0xFFA0A4B8))),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.faq,
    required this.index,
    required this.expanded,
    required this.onTap,
  });

  final _Faq faq;
  final int index;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(faq.q,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFA0A4B8),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Text(faq.a,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: const Color(0xFFA0A4B8),
                          height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.id,
    required this.subject,
    required this.status,
    required this.date,
    required this.statusColor,
  });

  final String id;
  final String subject;
  final String status;
  final String date;
  final Color statusColor;

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
          const Icon(Icons.confirmation_number_outlined,
              color: AppColors.accentGreen, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('$id  •  $date',
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFFA0A4B8))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(40),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(status,
                style: AppTextStyles.caption.copyWith(
                    color: statusColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Faq {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
}

