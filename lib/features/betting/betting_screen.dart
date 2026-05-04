import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/models/bet.dart';
import 'package:footsmart_pro/core/models/match.dart';
import 'package:footsmart_pro/core/models/wallet.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/bet_service.dart';
import 'package:footsmart_pro/core/services/match_service.dart';
import 'package:footsmart_pro/core/services/wallet_service.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/theme/app_spacing.dart';
import 'package:footsmart_pro/shared/widgets/app_badge.dart';
import 'package:footsmart_pro/shared/widgets/app_button.dart';
import 'package:footsmart_pro/shared/widgets/app_card.dart';
import 'package:footsmart_pro/shared/widgets/app_skeleton.dart';
import 'package:footsmart_pro/shared/widgets/app_text.dart';
import 'package:footsmart_pro/widgets/bottom_nav_bar.dart';

class BettingScreen extends StatefulWidget {
  const BettingScreen({super.key});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  late final MatchService _matchService;
  late final BetService _betService;
  late final WalletService _walletService;
  final NumberFormat _money =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final TextEditingController _stakeController =
      TextEditingController(text: '20');

  final List<double> _quickStakes = const [5, 10, 20, 50, 100, 250];

  List<FootballMatch> _matches = [];
  FootballMatch? _selectedMatch;
  MatchOdds? _selectedOdds;
  BetSelection _selectedSelection = BetSelection.home;

  bool _isMatchesLoading = true;
  bool _isOddsLoading = false;
  bool _isPlacingBet = false;
  Timer? _countdownTimer;

  String? _matchesError;
  String? _oddsError;

  double _stake = 20;
  int _points = 0;
  int _myBetsCount = 0;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _matchService = MatchService(api);
    _betService = BetService(api);
    _walletService = WalletService(api);
    _startCountdownTicker();
    _loadMatches();
    _refreshWalletAndBets();
  }

  void _startCountdownTicker() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _refreshWalletAndBets() async {
    try {
      final results = await Future.wait([
        _walletService.getBalance(),
        _betService.getMyBets(limit: 20),
      ]);

      final balance = results[0] as WalletBalance;
      final myBets = results[1] as MyBetsResponse;

      if (mounted) {
        setState(() {
          _points = balance.points;
          _myBetsCount = myBets.total;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stakeController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isMatchesLoading = true;
      _matchesError = null;
    });

    try {
      final response = await _matchService.getUpcomingMatches(
        limit: 80,
        nextGameweek: true,
      );

      final nextFixtures =
          response.matches.where((m) => m.isScheduled).toList();

      FootballMatch? selected;
      if (_selectedMatch != null) {
        for (final m in nextFixtures) {
          if (m.id == _selectedMatch!.id) {
            selected = m;
            break;
          }
        }
      }
      selected ??= nextFixtures.isNotEmpty ? nextFixtures.first : null;

      if (!mounted) return;

      setState(() {
        _matches = nextFixtures;
        _selectedMatch = selected;
        _isMatchesLoading = false;
      });

      if (selected != null) {
        await _loadOddsForMatch(selected);
      } else if (mounted) {
        setState(() {
          _selectedOdds = null;
          _oddsError = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _matchesError = e.toString();
        _isMatchesLoading = false;
      });
    }
  }

  Future<void> _loadOddsForMatch(FootballMatch match) async {
    setState(() {
      _isOddsLoading = true;
      _oddsError = null;
      _selectedOdds = null;
    });

    try {
      final odds = await _betService.getMatchOdds(match.id);
      if (!mounted) return;
      setState(() {
        _selectedOdds = odds;
        _selectedSelection = BetSelection.home;
        _isOddsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _oddsError = e.toString();
        _isOddsLoading = false;
      });
    }
  }

  void _selectMatch(FootballMatch match) {
    if (_selectedMatch?.id == match.id) return;
    setState(() {
      _selectedMatch = match;
    });
    _loadOddsForMatch(match);
  }

  void _setStake(double value, {bool syncText = true}) {
    final normalized = value.clamp(1, 10000).toDouble();
    setState(() {
      _stake = double.parse(normalized.toStringAsFixed(2));
    });

    if (syncText) {
      final text = _stake % 1 == 0
          ? _stake.toStringAsFixed(0)
          : _stake.toStringAsFixed(2);
      _stakeController.text = text;
    }
  }

  void _onStakeTyped(String input) {
    if (input.trim().isEmpty) return;
    final parsed = double.tryParse(input);
    if (parsed == null) return;
    _setStake(parsed, syncText: false);
  }

  BetSelection _smartSelection(MatchOdds odds) {
    final scores = {
      BetSelection.home: odds.homeProb,
      BetSelection.draw: odds.drawProb,
      BetSelection.away: odds.awayProb,
    };

    var best = BetSelection.home;
    var bestScore = scores[best]!;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        best = entry.key;
        bestScore = entry.value;
      }
    }

    return best;
  }

  String _riskLabel(double odds) {
    if (odds <= 1.8) return 'Low Risk';
    if (odds <= 2.7) return 'Medium Risk';
    return 'High Risk';
  }

  String _shortError(String? raw) {
    if (raw == null || raw.isEmpty) return 'Could not load data';
    final lower = raw.toLowerCase();
    if (lower.contains('no odds found')) {
      return 'Odds are not available for this match yet.';
    }
    if (lower.contains('odds missing')) {
      return 'Odds are currently missing for this match.';
    }
    if (lower.contains('insufficient points')) {
      return 'You do not have enough points.';
    }
    if (lower.contains('betting closed')) {
      return 'Betting is closed for this match.';
    }
    if (lower.contains('match not scheduled')) {
      return 'This match is no longer scheduled for betting.';
    }
    if (lower.contains('already settled')) {
      return 'This market has already been settled.';
    }
    return raw.replaceFirst('Exception: ', '');
  }

  int _secondsUntilClose(FootballMatch match) {
    if (match.betClosesAt != null) {
      final seconds =
          match.betClosesAt!.difference(DateTime.now().toUtc()).inSeconds;
      return seconds < 0 ? 0 : seconds;
    }

    return (match.secondsUntilClose ?? 0).clamp(0, 864000);
  }

  bool _isBettingOpenForMatch(FootballMatch match) {
    if (match.status != 'scheduled') return false;
    if (match.betClosesAt != null) {
      return DateTime.now().toUtc().isBefore(match.betClosesAt!);
    }
    if (match.isBettingOpen != null) {
      return match.isBettingOpen!;
    }
    return (match.secondsUntilClose ?? 0) > 0;
  }

  String _formatCountdown(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;

    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _matchTime(FootballMatch match) {
    if (match.matchDate != null) {
      return DateFormat('EEE, d MMM • HH:mm')
          .format(match.matchDate!.toLocal());
    }
    if (match.matchTime != null && match.matchTime!.isNotEmpty) {
      return match.matchTime!;
    }
    return 'Kickoff TBD';
  }

  String _selectionTitle(BetSelection selection, MatchOdds odds) {
    switch (selection) {
      case BetSelection.home:
        return odds.homeTeam;
      case BetSelection.draw:
        return 'Draw';
      case BetSelection.away:
        return odds.awayTeam;
    }
  }

  double get _selectedOddsValue {
    if (_selectedOdds == null) return 0;
    return _selectedOdds!.oddsFor(_selectedSelection);
  }

  double get _potentialPayout => _stake * _selectedOddsValue;

  Future<void> _placeBet() async {
    final match = _selectedMatch;
    final odds = _selectedOdds;
    if (match == null || odds == null) return;

    if (!_isBettingOpenForMatch(match)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Betting is closed for this match.')),
      );
      return;
    }

    if (_stake <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid stake amount.')),
      );
      return;
    }

    if (_points < _stake) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient points. You have $_points pts.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {
      final result = await _betService.placeBet(
        matchId: match.id,
        selection: _selectedSelection,
        stake: _stake,
      );

      if (!mounted) return;

      setState(() {
        _points = result.pointsAfter;
        _myBetsCount += 1;
      });

      await _refreshWalletAndBets();
      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        backgroundColor: context.scaffoldBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded,
                  color: AppColors.success, size: 44),
              const SizedBox(height: 10),
              Text(
                'Bet Confirmed',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.bet.selectionLabel,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              _sheetRow(context, 'Stake', _money.format(result.bet.stake)),
              _sheetRow(context, 'Odds', result.bet.odds.toStringAsFixed(2)),
              _sheetRow(context, 'Potential payout',
                  _money.format(result.bet.potentialPayout)),
              const SizedBox(height: 8),
              Divider(color: context.borderSubtle, height: 1),
              const SizedBox(height: 8),
              _sheetRow(
                  context, 'Points remaining', '${result.pointsAfter} pts',
                  emphasize: true),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accent,
                    foregroundColor: context.surfaceBg,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          content: Text(_shortError(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingBet = false;
        });
      }
    }
  }

  Widget _sheetRow(BuildContext context, String label, String value,
      {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: emphasize ? context.accent : context.textPrimary,
              fontSize: emphasize ? 16 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () {
            if (AppRoutes.canPop(context)) {
              AppRoutes.pop(context);
            } else {
              AppRoutes.replace(context, AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Bet Studio',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadMatches,
            icon: Icon(Icons.refresh_rounded, color: context.accent),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMatches,
              color: context.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
                children: [
                  _HeroPanel(
                    matchesCount: _matches.length,
                    isLoading: _isMatchesLoading,
                    accent: context.accent,
                    cardBg: context.cardBg,
                    border: context.borderSubtle,
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle(
                    title: '1. Pick Match',
                    subtitle: 'Next gameweek fixtures only',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_isMatchesLoading)
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (_, __) => const AppSkeleton(
                          width: 240,
                          height: 170,
                        ),
                      ),
                    )
                  else if (_matchesError != null)
                    _ErrorCard(
                      message: 'Could not load matches',
                      detail: _shortError(_matchesError),
                      onRetry: _loadMatches,
                    )
                  else if (_matches.isEmpty)
                    const _EmptyCard(
                      message: 'No fixtures found for the next gameweek.',
                    )
                  else
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _matches.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final match = _matches[index];
                          final secondsUntilClose = _secondsUntilClose(match);
                          final bettingOpen = _isBettingOpenForMatch(match);
                          return _MatchCard(
                            match: match,
                            selected: _selectedMatch?.id == match.id,
                            dateLabel: _matchTime(match),
                            countdownLabel: bettingOpen
                                ? 'Bet closes in ${_formatCountdown(secondsUntilClose)}'
                                : 'Betting closed',
                            bettingOpen: bettingOpen,
                            onTap: () => _selectMatch(match),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  const _SectionTitle(
                    title: '2. Pick Outcome',
                    subtitle: 'Live market odds and model probability',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_selectedMatch == null)
                    const _EmptyCard(message: 'Select a match to continue.')
                  else if (_isOddsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(child: AppSkeleton(height: 116)),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(child: AppSkeleton(height: 116)),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(child: AppSkeleton(height: 116)),
                        ],
                      ),
                    )
                  else if (_selectedOdds == null)
                    _ErrorCard(
                      message: 'Odds unavailable',
                      detail: _shortError(_oddsError),
                      onRetry: () {
                        final selected = _selectedMatch;
                        if (selected != null) {
                          _loadOddsForMatch(selected);
                        }
                      },
                    )
                  else ...[
                    _SmartTipCard(
                      odds: _selectedOdds!,
                      recommended: _smartSelection(_selectedOdds!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _OutcomeCard(
                            title: _selectedOdds!.homeTeam,
                            odds: _selectedOdds!.homeOdds,
                            probability: _selectedOdds!.homeProb,
                            selected: _selectedSelection == BetSelection.home,
                            onTap: () => setState(
                                () => _selectedSelection = BetSelection.home),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OutcomeCard(
                            title: 'Draw',
                            odds: _selectedOdds!.drawOdds,
                            probability: _selectedOdds!.drawProb,
                            selected: _selectedSelection == BetSelection.draw,
                            onTap: () => setState(
                                () => _selectedSelection = BetSelection.draw),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OutcomeCard(
                            title: _selectedOdds!.awayTeam,
                            odds: _selectedOdds!.awayOdds,
                            probability: _selectedOdds!.awayProb,
                            selected: _selectedSelection == BetSelection.away,
                            onTap: () => setState(
                                () => _selectedSelection = BetSelection.away),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  const _SectionTitle(
                    title: '3. Stake Lab',
                    subtitle: 'Type, tap preset, or slide to set amount',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded,
                            color: context.accent, size: 18),
                        const SizedBox(width: 6),
                        AppText(
                          'Available: $_points pts',
                          variant: AppTextVariant.body,
                          tone: AppTextTone.info,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          'My bets: $_myBetsCount',
                          variant: AppTextVariant.caption,
                          tone: AppTextTone.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StakePanel(
                    stakeController: _stakeController,
                    stake: _stake,
                    onStakeChanged: _onStakeTyped,
                    onSliderChanged: (v) => _setStake(v),
                    quickStakes: _quickStakes,
                    onQuickStakeTap: (v) => _setStake(v),
                  ),
                  const SizedBox(height: 20),
                  _BetSlipPanel(
                    hasOdds: _selectedOdds != null,
                    selectionLabel: _selectedOdds == null
                        ? 'Select a market'
                        : _selectionTitle(_selectedSelection, _selectedOdds!),
                    stakeLabel: _money.format(_stake),
                    oddsLabel: _selectedOdds == null
                        ? '-'
                        : _selectedOddsValue.toStringAsFixed(2),
                    payoutLabel: _money.format(_potentialPayout),
                    riskLabel: _riskLabel(_selectedOddsValue),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A65).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFF8A65).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Color(0xFFFF8A65), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Play smart. Set limits and only bet what you are comfortable losing.',
                            style: TextStyle(
                              color: Color(0xFFFF8A65),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ActionBar(
            disabled: _selectedOdds == null ||
                _selectedMatch == null ||
                _isPlacingBet ||
              _points < _stake ||
              (_selectedMatch != null &&
                !_isBettingOpenForMatch(_selectedMatch!)),
            placing: _isPlacingBet,
            buttonLabel: _selectedOdds == null
                ? 'Odds Unavailable'
              : (_selectedMatch != null &&
                  !_isBettingOpenForMatch(_selectedMatch!))
                ? 'Betting Closed'
                : 'Bet ${_stake.toInt()} pts • Win ${_potentialPayout.toInt()} pts',
            onPlace: _placeBet,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            AppRoutes.push(context, AppRoutes.home);
          } else if (index == 1) {
            AppRoutes.push(context, AppRoutes.explore);
          } else if (index == 3) {
            AppRoutes.push(context, AppRoutes.wallet);
          } else if (index == 4) {
            AppRoutes.push(context, AppRoutes.profile);
          }
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final int matchesCount;
  final bool isLoading;
  final Color accent;
  final Color cardBg;
  final Color border;

  const _HeroPanel({
    required this.matchesCount,
    required this.isLoading,
    required this.accent,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.22),
              cardBg,
            ],
          ),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_graph_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Today\'s Trading Floor',
                      variant: AppTextVariant.h3,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      isLoading
                          ? 'Syncing next gameweek...'
                          : '$matchesCount fixtures open for pricing',
                      variant: AppTextVariant.caption,
                      tone: AppTextTone.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              const AppBadge(
                label: 'Next GW',
                variant: AppBadgeVariant.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: AppTextVariant.h3,
          fontWeight: FontWeight.w800,
        ),
        const SizedBox(height: 2),
        AppText(
          subtitle,
          variant: AppTextVariant.caption,
          tone: AppTextTone.secondary,
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final FootballMatch match;
  final bool selected;
  final String dateLabel;
  final String countdownLabel;
  final bool bettingOpen;
  final VoidCallback onTap;

  const _MatchCard({
    required this.match,
    required this.selected,
    required this.dateLabel,
    required this.countdownLabel,
    required this.bettingOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? context.accent.withValues(alpha: 0.14)
              : context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? context.accent : context.borderSubtle,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.leagueName ?? 'League',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${match.homeTeam.name} vs ${match.awayTeam.name}',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: context.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              countdownLabel,
              style: TextStyle(
                color: bettingOpen ? context.accent : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartTipCard extends StatelessWidget {
  final MatchOdds odds;
  final BetSelection recommended;

  const _SmartTipCard({required this.odds, required this.recommended});

  @override
  Widget build(BuildContext context) {
    final label = odds.labelFor(recommended);
    final probability = odds.probabilityFor(recommended).toStringAsFixed(1);

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: context.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              'Smart tip: $label looks most probable at $probability%.',
              variant: AppTextVariant.body,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  final String title;
  final double odds;
  final double probability;
  final bool selected;
  final VoidCallback onTap;

  const _OutcomeCard({
    required this.title,
    required this.odds,
    required this.probability,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? context.accent.withValues(alpha: 0.16)
              : context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? context.accent : context.borderSubtle,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? context.accent : context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              odds.toStringAsFixed(2),
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${probability.toStringAsFixed(1)}%',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StakePanel extends StatelessWidget {
  final TextEditingController stakeController;
  final double stake;
  final ValueChanged<String> onStakeChanged;
  final ValueChanged<double> onSliderChanged;
  final List<double> quickStakes;
  final ValueChanged<double> onQuickStakeTap;

  const _StakePanel({
    required this.stakeController,
    required this.stake,
    required this.onStakeChanged,
    required this.onSliderChanged,
    required this.quickStakes,
    required this.onQuickStakeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          TextField(
            controller: stakeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onStakeChanged,
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: context.accent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
              hintText: 'Enter stake',
              hintStyle: TextStyle(color: context.textSecondary),
              filled: true,
              fillColor: context.surfaceBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.accent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.accent,
              thumbColor: context.accent,
              inactiveTrackColor: context.borderSubtle,
              overlayColor: context.accent.withValues(alpha: 0.18),
            ),
            child: Slider(
              value: stake.clamp(1, 1000),
              min: 1,
              max: 1000,
              divisions: 999,
              label: '\$${stake.toStringAsFixed(0)}',
              onChanged: onSliderChanged,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickStakes
                .map(
                  (amount) => GestureDetector(
                    onTap: () => onQuickStakeTap(amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: (stake - amount).abs() < 0.01
                            ? context.accent.withValues(alpha: 0.2)
                            : context.surfaceBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: (stake - amount).abs() < 0.01
                              ? context.accent
                              : context.borderSubtle,
                        ),
                      ),
                      child: Text(
                        '\$${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: (stake - amount).abs() < 0.01
                              ? context.accent
                              : context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BetSlipPanel extends StatelessWidget {
  final bool hasOdds;
  final String selectionLabel;
  final String stakeLabel;
  final String oddsLabel;
  final String payoutLabel;
  final String riskLabel;

  const _BetSlipPanel({
    required this.hasOdds,
    required this.selectionLabel,
    required this.stakeLabel,
    required this.oddsLabel,
    required this.payoutLabel,
    required this.riskLabel,
  });

  AppBadgeVariant _badgeVariant() {
    if (riskLabel.contains('Low')) return AppBadgeVariant.success;
    if (riskLabel.contains('Medium')) return AppBadgeVariant.warning;
    return AppBadgeVariant.danger;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: context.accent, size: 18),
              const SizedBox(width: 8),
              const AppText(
                'Live Bet Slip',
                variant: AppTextVariant.h3,
                fontWeight: FontWeight.w800,
              ),
              const Spacer(),
              if (hasOdds)
                AppBadge(
                  label: riskLabel,
                  variant: _badgeVariant(),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _row(context, 'Selection', selectionLabel),
          _row(context, 'Stake', stakeLabel),
          _row(context, 'Odds', oddsLabel),
          const SizedBox(height: 8),
          Divider(color: context.borderSubtle, height: 1),
          const SizedBox(height: 8),
          _row(context, 'Potential payout', payoutLabel, emphasize: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String title, String value,
      {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            title,
            variant: AppTextVariant.caption,
            tone: AppTextTone.secondary,
          ),
          AppText(
            value,
            variant: emphasize ? AppTextVariant.bodyLarge : AppTextVariant.body,
            tone: emphasize ? AppTextTone.info : AppTextTone.primary,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool disabled;
  final bool placing;
  final String buttonLabel;
  final VoidCallback onPlace;

  const _ActionBar({
    required this.disabled,
    required this.placing,
    required this.buttonLabel,
    required this.onPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        border: Border(top: BorderSide(color: context.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: buttonLabel,
          onPressed: disabled ? null : onPlace,
          isLoading: placing,
          fullWidth: true,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            message,
            variant: AppTextVariant.body,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          AppText(
            detail,
            variant: AppTextVariant.caption,
            tone: AppTextTone.secondary,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.ghost,
            onPressed: onRetry,
            fullWidth: false,
            size: AppButtonSize.sm,
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AppText(
        message,
        variant: AppTextVariant.body,
        tone: AppTextTone.secondary,
      ),
    );
  }
}
