import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/models/bet.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/bet_service.dart';

// ─── Filtre ──────────────────────────────────────────────────────────────────
enum _Filter {
  all('All', null),
  pending('Pending', 'pending'),
  won('Won', 'won'),
  lost('Lost', 'lost');

  const _Filter(this.label, this.apiValue);
  final String label;
  final String? apiValue;
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class BettingHistoryScreen extends StatefulWidget {
  const BettingHistoryScreen({super.key});

  @override
  State<BettingHistoryScreen> createState() => _BettingHistoryScreenState();
}

class _BettingHistoryScreenState extends State<BettingHistoryScreen> {
  late final BetService _betService;
  late final AuthService _authService;

  _Filter _filter = _Filter.all;
  List<PlacedBet> _bets = [];
  int _total = 0;
  bool _isLoading = true;
  String? _error;

  final NumberFormat _money =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _betService = BetService(api);
    _authService = AuthService(api);
    _loadBets();
  }

  Future<void> _loadBets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // S'assurer que le token est bien injecté dans ApiService
      await _authService.syncTokenToApi();

      final response = await _betService.getMyBets(
        status: _filter.apiValue,
        limit: 100,
      );

      if (!mounted) return;
      setState(() {
        _bets = response.bets;
        _total = response.total;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(_Filter f) {
    if (_filter == f) return;
    setState(() => _filter = f);
    _loadBets();
  }

  // ── Stats calculées depuis les données réelles ──────────────────────────
  int get _wonCount => _bets.where((b) => b.status == 'won').length;
  int get _lostCount => _bets.where((b) => b.status == 'lost').length;
  int get _pendingCount => _bets.where((b) => b.status == 'pending').length;

  double get _totalStaked => _bets.fold(0.0, (s, b) => s + b.stake);

  double get _totalReturned => _bets
      .where((b) => b.status == 'won')
      .fold(0.0, (s, b) => s + b.potentialPayout);

  double get _profit => _totalReturned - _totalStaked;

  double get _winRate =>
      _bets.isEmpty ? 0 : (_wonCount / _bets.length) * 100;

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
        title: Text(
          'Betting History',
          style: AppTextStyles.h4.copyWith(color: AppColors.textWhite),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadBets,
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.accentGreen, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats bar ──
          if (!_isLoading && _error == null) _buildStatsBar(),

          const SizedBox(height: 16),

          // ── Filtres ──
          _buildFilterChips(),

          const SizedBox(height: 16),

          // ── Contenu principal ──
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Stats Bar ─────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    final profitPositive = _profit >= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          // Ligne 1 : Total / Won / Lost / Pending
          Row(
            children: [
              _StatChip(
                label: 'Total',
                value: '$_total',
                color: AppColors.textWhite,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Won',
                value: '$_wonCount',
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Lost',
                value: '$_lostCount',
                color: AppColors.betLoss,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Pending',
                value: '$_pendingCount',
                color: AppColors.accentOrange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ligne 2 : Win Rate / Profit
          Row(
            children: [
              _StatChip(
                label: 'Win Rate',
                value: '${_winRate.toStringAsFixed(0)}%',
                color: _winRate >= 50
                    ? AppColors.accentGreen
                    : AppColors.betLoss,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Staked',
                value: _money.format(_totalStaked),
                color: AppColors.textWhite,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Profit',
                value:
                    '${profitPositive ? '+' : ''}${_money.format(_profit)}',
                color: profitPositive
                    ? AppColors.accentGreen
                    : AppColors.betLoss,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _Filter.values.map((f) {
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _onFilterChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentGreen
                      : const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? AppColors.accentGreen
                        : const Color(0xFF252B3D),
                  ),
                ),
                child: Text(
                  f.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? const Color(0xFF0B1220)
                        : AppColors.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Corps principal ───────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen),
      );
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadBets);
    }

    if (_bets.isEmpty) {
      return _EmptyState(filter: _filter);
    }

    return RefreshIndicator(
      onRefresh: _loadBets,
      color: AppColors.accentGreen,
      backgroundColor: const Color(0xFF1A1F2E),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: _bets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _BetCard(
          bet: _bets[i],
          moneyFmt: _money,
        ),
      ),
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

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
            Text(
              value,
              style: AppTextStyles.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFFA0A4B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bet Card ─────────────────────────────────────────────────────────────────
class _BetCard extends StatelessWidget {
  const _BetCard({required this.bet, required this.moneyFmt});

  final PlacedBet bet;
  final NumberFormat moneyFmt;

  // Détermine visuellement si on a gagné, perdu ou si c'est en attente
  _BetVisual get _visual {
    switch (bet.status) {
      case 'won':
        return _BetVisual(
          label: 'WON',
          icon: Icons.check_circle_rounded,
          color: AppColors.accentGreen,
          bgColor: const Color(0x2200FF88),
          payoutLabel: 'Payout',
          payoutValue: bet.potentialPayout,
          payoutColor: AppColors.accentGreen,
        );
      case 'lost':
        return _BetVisual(
          label: 'LOST',
          icon: Icons.cancel_rounded,
          color: AppColors.betLoss,
          bgColor: const Color(0x22FF4444),
          payoutLabel: 'Lost',
          payoutValue: -bet.stake,
          payoutColor: AppColors.betLoss,
        );
      case 'cancelled':
        return _BetVisual(
          label: 'CANCELLED',
          icon: Icons.block_rounded,
          color: const Color(0xFFA0A4B8),
          bgColor: const Color(0x22A0A4B8),
          payoutLabel: 'Refunded',
          payoutValue: bet.stake,
          payoutColor: const Color(0xFFA0A4B8),
        );
      default: // pending
        return _BetVisual(
          label: 'PENDING',
          icon: Icons.schedule_rounded,
          color: AppColors.accentOrange,
          bgColor: const Color(0x22FF7A00),
          payoutLabel: 'Waiting Result',
          payoutValue: bet.potentialPayout,
          payoutColor: AppColors.accentOrange,
        );
    }
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy • HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;

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
          // ── Ligne du haut : match + badge statut ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bet.homeTeam} vs ${bet.awayTeam}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bet.selectionLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFFA0A4B8),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bet.status == 'pending'
                          ? 'Placed ${_formatDate(bet.createdAt)} • Waiting for result'
                          : 'Settled ${_formatDate(bet.settledAt ?? bet.createdAt)}',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Badge statut
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: v.bgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(v.icon, size: 12, color: v.color),
                    const SizedBox(width: 5),
                    Text(
                      v.label,
                      style: AppTextStyles.overline.copyWith(
                        color: v.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: const Color(0xFF252B3D).withValues(alpha: 0.8), height: 1),
          const SizedBox(height: 12),

          // ── Métriques : Stake / Odds / Payout ──
          Row(
            children: [
              _Metric(
                label: 'Stake',
                value: moneyFmt.format(bet.stake),
                color: AppColors.textWhite,
              ),
              _Metric(
                label: 'Odds',
                value: bet.odds.toStringAsFixed(2),
                color: AppColors.textWhite,
              ),
              _Metric(
                label: v.payoutLabel,
                value: v.payoutValue < 0
                    ? '-${moneyFmt.format(v.payoutValue.abs())}'
                    : moneyFmt.format(v.payoutValue),
                color: v.payoutColor,
                bold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Metric (colonne Stake/Odds/Payout) ──────────────────────────────────────
class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.color = AppColors.textWhite,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFFA0A4B8),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Données visuelles pour un statut ────────────────────────────────────────
class _BetVisual {
  const _BetVisual({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.payoutLabel,
    required this.payoutValue,
    required this.payoutColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String payoutLabel;
  final double payoutValue;
  final Color payoutColor;
}

// ─── État vide ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final _Filter filter;

  @override
  Widget build(BuildContext context) {
    final messages = {
      _Filter.all: 'No bets placed yet.\nGo to Bet Studio to place your first bet!',
      _Filter.pending: 'No pending bets.\nAll your bets have been settled.',
      _Filter.won: 'No winning bets yet.\nKeep trying — your win is coming!',
      _Filter.lost: 'No lost bets in this filter.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter == _Filter.won
                  ? Icons.emoji_events_rounded
                  : Icons.receipt_long_rounded,
              size: 64,
              color: const Color(0xFF252B3D),
            ),
            const SizedBox(height: 16),
            Text(
              messages[filter] ?? 'No bets found.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFFA0A4B8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── État d'erreur ────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.betLoss),
            const SizedBox(height: 14),
            Text(
              'Could not load your bets',
              style: AppTextStyles.h4.copyWith(color: AppColors.textWhite),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFA0A4B8),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: const Color(0xFF0B1220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
