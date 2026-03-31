import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class BettingHistoryScreen extends StatefulWidget {
  const BettingHistoryScreen({super.key});

  @override
  State<BettingHistoryScreen> createState() => _BettingHistoryScreenState();
}

class _BettingHistoryScreenState extends State<BettingHistoryScreen> {
  _Filter _filter = _Filter.all;

  // 47 total | 30 won (63%) | 17 lost | staked $290 | returned $342 | profit $52 | ROI +18%
  static const List<_BetEntry> _allBets = [
    // ── Feb 2026 ──────────────────────────────────────────────────────────
    _BetEntry(
      match: 'Man City vs Liverpool',
      market: 'Man City Win',
      stake: 10.0, odds: 1.80, payout: 18.00,
      date: 'Feb 13, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Barcelona vs Real Madrid',
      market: 'Match Result – Draw',
      stake: 5.0, odds: 3.40, payout: 0,
      date: 'Feb 12, 2026', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Bayern vs Dortmund',
      market: 'Bayern Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Feb 11, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Arsenal vs Chelsea',
      market: 'Both Teams to Score',
      stake: 5.0, odds: 2.00, payout: 10.00,
      date: 'Feb 10, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Juventus vs Inter Milan',
      market: 'Juventus Win',
      stake: 10.0, odds: 2.60, payout: 0,
      date: 'Feb 9, 2026', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Atletico Madrid vs Sevilla',
      market: 'Under 2.5 Goals',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Feb 7, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'PSG vs Lyon',
      market: 'PSG Win & Over 1.5',
      stake: 10.0, odds: 1.90, payout: 19.00,
      date: 'Feb 6, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Tottenham vs West Ham',
      market: 'Tottenham Win',
      stake: 5.0, odds: 2.20, payout: 0,
      date: 'Feb 5, 2026', result: _Result.lost,
    ),
    // ── Jan 2026 ──────────────────────────────────────────────────────────
    _BetEntry(
      match: 'Real Madrid vs Villarreal',
      market: 'Real Madrid Win',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Jan 31, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'AC Milan vs Napoli',
      market: 'Over 2.5 Goals',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Jan 29, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Liverpool vs Everton',
      market: 'Liverpool Win',
      stake: 10.0, odds: 1.85, payout: 18.50,
      date: 'Jan 27, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Dortmund vs Leipzig',
      market: 'Draw',
      stake: 5.0, odds: 3.50, payout: 0,
      date: 'Jan 25, 2026', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Chelsea vs Man United',
      market: 'Both Teams to Score',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Jan 23, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Sevilla vs Valencia',
      market: 'Sevilla Win',
      stake: 5.0, odds: 2.00, payout: 10.00,
      date: 'Jan 21, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Inter Milan vs Atalanta',
      market: 'Inter Win',
      stake: 10.0, odds: 1.70, payout: 0,
      date: 'Jan 19, 2026', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Porto vs Benfica',
      market: 'Over 2.5 Goals',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Jan 17, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Man City vs Arsenal',
      market: 'Man City Win',
      stake: 10.0, odds: 1.80, payout: 0,
      date: 'Jan 15, 2026', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Lyon vs Monaco',
      market: 'Under 2.5 Goals',
      stake: 5.0, odds: 2.10, payout: 10.50,
      date: 'Jan 13, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Ajax vs PSV',
      market: 'Ajax Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Jan 11, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Real Sociedad vs Athletic',
      market: 'Draw',
      stake: 5.0, odds: 3.20, payout: 0,
      date: 'Jan 9, 2026', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Marseille vs Rennes',
      market: 'Marseille Win',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Jan 7, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Wolves vs Aston Villa',
      market: 'Aston Villa Win',
      stake: 5.0, odds: 2.10, payout: 10.50,
      date: 'Jan 5, 2026', result: _Result.won,
    ),
    _BetEntry(
      match: 'Fiorentina vs Lazio',
      market: 'Over 2.5 Goals',
      stake: 5.0, odds: 1.95, payout: 0,
      date: 'Jan 3, 2026', result: _Result.lost,
    ),
    // ── Dec 2025 ──────────────────────────────────────────────────────────
    _BetEntry(
      match: 'Newcastle vs Brighton',
      market: 'Newcastle Win',
      stake: 10.0, odds: 1.75, payout: 17.50,
      date: 'Dec 29, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Dortmund vs Bayer',
      market: 'Dortmund Win',
      stake: 5.0, odds: 2.30, payout: 0,
      date: 'Dec 27, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Celtic vs Rangers',
      market: 'Celtic Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Dec 24, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Napoli vs Roma',
      market: 'Napoli Win',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Dec 21, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Leicester vs Nottm Forest',
      market: 'Both Teams to Score',
      stake: 5.0, odds: 1.70, payout: 0,
      date: 'Dec 18, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Sporting CP vs Braga',
      market: 'Sporting Win',
      stake: 5.0, odds: 2.10, payout: 10.50,
      date: 'Dec 15, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Barca vs Girona',
      market: 'Barca Win',
      stake: 10.0, odds: 1.60, payout: 16.00,
      date: 'Dec 12, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Man United vs Fulham',
      market: 'Man United Win',
      stake: 10.0, odds: 2.00, payout: 0,
      date: 'Dec 9, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Lazio vs Torino',
      market: 'Lazio Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Dec 6, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Rennes vs Nice',
      market: 'Over 2.5 Goals',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Dec 3, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'PSV vs Feyenoord',
      market: 'PSV Win',
      stake: 5.0, odds: 1.95, payout: 0,
      date: 'Dec 1, 2025', result: _Result.lost,
    ),
    // ── Nov 2025 ──────────────────────────────────────────────────────────
    _BetEntry(
      match: 'Everton vs Southampton',
      market: 'Everton Win',
      stake: 5.0, odds: 2.10, payout: 10.50,
      date: 'Nov 28, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Ipswich vs Crystal Palace',
      market: 'Crystal Palace Win',
      stake: 5.0, odds: 2.00, payout: 0,
      date: 'Nov 25, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Real Betis vs Celta',
      market: 'Under 2.5 Goals',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Nov 22, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Sampdoria vs Genoa',
      market: 'Both Teams to Score',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Nov 19, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Leipzig vs Gladbach',
      market: 'Leipzig Win',
      stake: 10.0, odds: 1.80, payout: 0,
      date: 'Nov 16, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Porto vs Sporting',
      market: 'Draw',
      stake: 5.0, odds: 3.30, payout: 0,
      date: 'Nov 13, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'Brighton vs Brentford',
      market: 'Brighton Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Nov 10, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Osasuna vs Mallorca',
      market: 'Under 2.5 Goals',
      stake: 5.0, odds: 1.95, payout: 9.75,
      date: 'Nov 7, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'AC Milan vs Udinese',
      market: 'AC Milan Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Nov 4, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Lens vs Strasbourg',
      market: 'Lens Win',
      stake: 5.0, odds: 2.00, payout: 0,
      date: 'Nov 1, 2025', result: _Result.lost,
    ),
    // ── Oct 2025 ──────────────────────────────────────────────────────────
    _BetEntry(
      match: 'Villarreal vs Valencia',
      market: 'Villarreal Win',
      stake: 5.0, odds: 2.05, payout: 10.25,
      date: 'Oct 30, 2025', result: _Result.won,
    ),
    _BetEntry(
      match: 'Roma vs Fiorentina',
      market: 'Over 2.5 Goals',
      stake: 10.0, odds: 1.75, payout: 0,
      date: 'Oct 27, 2025', result: _Result.lost,
    ),
    _BetEntry(
      match: 'West Ham vs Palace',
      market: 'West Ham Win',
      stake: 5.0, odds: 2.10, payout: 10.50,
      date: 'Oct 24, 2025', result: _Result.won,
    ),
  ];

  List<_BetEntry> get _displayed {
    switch (_filter) {
      case _Filter.all:
        return _allBets;
      case _Filter.won:
        return _allBets.where((b) => b.result == _Result.won).toList();
      case _Filter.lost:
        return _allBets.where((b) => b.result == _Result.lost).toList();
      case _Filter.pending:
        return _allBets.where((b) => b.result == _Result.pending).toList();
    }
  }

  // summary stats
  int get _wonCount =>
      _allBets.where((b) => b.result == _Result.won).length;
  int get _lostCount =>
      _allBets.where((b) => b.result == _Result.lost).length;
  double get _totalWon =>
      _allBets.fold(0, (s, b) => s + (b.result == _Result.won ? b.payout : 0));
  double get _totalStaked => _allBets.fold(0, (s, b) => s + b.stake);

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
        title: Text('Betting History',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // stats bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                _StatChip(
                    label: 'Total Bets',
                    value: '${_allBets.length}',
                    color: AppColors.textWhite),
                const SizedBox(width: 10),
                _StatChip(
                    label: 'Won',
                    value: '$_wonCount',
                    color: AppColors.accentGreen),
                const SizedBox(width: 10),
                _StatChip(
                    label: 'Lost',
                    value: '$_lostCount',
                    color: const Color(0xFFF87171)),
                const SizedBox(width: 10),
                _StatChip(
                    label: 'Profit',
                    value:
                        '${(_totalWon - _totalStaked) >= 0 ? '+' : ''}\$${(_totalWon - _totalStaked).toStringAsFixed(0)}',
                    color: (_totalWon - _totalStaked) >= 0
                        ? AppColors.accentGreen
                        : const Color(0xFFF87171)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: _Filter.values.map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentGreen
                            : const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: const Color(0xFF252B3D)),
                      ),
                      child: Text(
                        f.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: selected
                              ? const Color(0xFF0B1220)
                              : AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _displayed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _BetCard(bet: _displayed[i]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

enum _Filter {
  all('All'),
  won('Won'),
  lost('Lost'),
  pending('Pending');

  const _Filter(this.label);
  final String label;
}

enum _Result { won, lost, pending }

class _BetEntry {
  const _BetEntry({
    required this.match,
    required this.market,
    required this.stake,
    required this.odds,
    required this.payout,
    required this.date,
    required this.result,
  });

  final String match;
  final String market;
  final double stake;
  final double odds;
  final double payout;
  final String date;
  final _Result result;
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF252B3D)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.h4
                    .copyWith(color: color, fontWeight: FontWeight.bold)),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: const Color(0xFFA0A4B8))),
          ],
        ),
      ),
    );
  }
}

class _BetCard extends StatelessWidget {
  const _BetCard({required this.bet});
  final _BetEntry bet;

  @override
  Widget build(BuildContext context) {
    Color resultColor;
    String resultLabel;
    Color resultBg;
    IconData resultIcon;

    switch (bet.result) {
      case _Result.won:
        resultColor = AppColors.accentGreen;
        resultBg = const Color(0x3300FF88);
        resultLabel = 'WON';
        resultIcon = Icons.check_circle_rounded;
      case _Result.lost:
        resultColor = const Color(0xFFF87171);
        resultBg = const Color(0x33F87171);
        resultLabel = 'LOST';
        resultIcon = Icons.cancel_rounded;
      case _Result.pending:
        resultColor = AppColors.accentOrange;
        resultBg = const Color(0x33FF7A00);
        resultLabel = 'PENDING';
        resultIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bet.match,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(bet.market,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: const Color(0xFFA0A4B8))),
                    const SizedBox(height: 4),
                    Text(bet.date,
                        style: AppTextStyles.caption
                            .copyWith(color: const Color(0xFFA0A4B8))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: resultBg,
                    borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(resultIcon, size: 12, color: resultColor),
                    const SizedBox(width: 4),
                    Text(resultLabel,
                        style: AppTextStyles.overline.copyWith(
                            color: resultColor, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF252B3D), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(label: 'Stake', value: '\$${bet.stake}'),
              _Metric(label: 'Odds', value: '${bet.odds}'),
              _Metric(
                label: bet.result == _Result.pending
                    ? 'Potential Win'
                    : bet.result == _Result.won
                        ? 'Payout'
                        : 'Lost',
                value: bet.result == _Result.lost
                    ? '-\$${bet.stake}'
                    : '\$${(bet.result == _Result.pending ? bet.stake * bet.odds : bet.payout).toStringAsFixed(2)}',
                color: bet.result == _Result.lost
                    ? const Color(0xFFF87171)
                    : AppColors.accentGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.label, required this.value, this.color = Colors.white});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: const Color(0xFFA0A4B8))),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

