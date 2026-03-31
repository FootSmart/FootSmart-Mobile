enum BetSelection {
  home,
  draw,
  away;

  String get apiValue => name;

  static BetSelection fromApi(String value) {
    return values.firstWhere(
      (selection) => selection.apiValue == value,
      orElse: () => BetSelection.home,
    );
  }
}

class MatchOdds {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final double homeProb;
  final double drawProb;
  final double awayProb;
  final double homeOdds;
  final double drawOdds;
  final double awayOdds;

  const MatchOdds({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
  });

  factory MatchOdds.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return MatchOdds(
      matchId: json['matchId'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeProb: parseNum(json['homeProb']),
      drawProb: parseNum(json['drawProb']),
      awayProb: parseNum(json['awayProb']),
      homeOdds: parseNum(json['homeOdds']),
      drawOdds: parseNum(json['drawOdds']),
      awayOdds: parseNum(json['awayOdds']),
    );
  }

  double oddsFor(BetSelection selection) {
    switch (selection) {
      case BetSelection.home:
        return homeOdds;
      case BetSelection.draw:
        return drawOdds;
      case BetSelection.away:
        return awayOdds;
    }
  }

  double probabilityFor(BetSelection selection) {
    switch (selection) {
      case BetSelection.home:
        return homeProb;
      case BetSelection.draw:
        return drawProb;
      case BetSelection.away:
        return awayProb;
    }
  }

  String labelFor(BetSelection selection) {
    switch (selection) {
      case BetSelection.home:
        return '$homeTeam Win';
      case BetSelection.draw:
        return 'Draw';
      case BetSelection.away:
        return '$awayTeam Win';
    }
  }
}

class PlacedBet {
  final String id;
  final String userId;
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final BetSelection selection;
  final String selectionLabel;
  final double stake;
  final double odds;
  final double potentialPayout;
  final String status;
  final DateTime createdAt;

  const PlacedBet({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.selection,
    required this.selectionLabel,
    required this.stake,
    required this.odds,
    required this.potentialPayout,
    required this.status,
    required this.createdAt,
  });

  factory PlacedBet.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return PlacedBet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      matchId: json['matchId'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      selection: BetSelection.fromApi(json['selection'] as String),
      selectionLabel: json['selectionLabel'] as String,
      stake: parseNum(json['stake']),
      odds: parseNum(json['odds']),
      potentialPayout: parseNum(json['potentialPayout']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PlaceBetResult {
  final bool success;
  final String message;
  final PlacedBet bet;
  final double balanceBefore;
  final double balanceAfter;
  final double debited;

  const PlaceBetResult({
    required this.success,
    required this.message,
    required this.bet,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.debited,
  });

  factory PlaceBetResult.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final wallet = json['wallet'] as Map<String, dynamic>? ?? {};

    return PlaceBetResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Bet placed',
      bet: PlacedBet.fromJson(json['bet'] as Map<String, dynamic>),
      balanceBefore: parseNum(wallet['balanceBefore']),
      balanceAfter: parseNum(wallet['balanceAfter']),
      debited: parseNum(wallet['debited']),
    );
  }
}
