import 'player.dart';

/// Team model matching backend TeamDto
class Team {
  final String id;
  final String? leagueId;
  final String? leagueName;
  final String name;
  final String? shortName;
  final String? logo;
  final String? country;
  final String? stadium;
  final int? stadiumCapacity;
  final int? foundedYear;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Team({
    required this.id,
    this.leagueId,
    this.leagueName,
    required this.name,
    this.shortName,
    this.logo,
    this.country,
    this.stadium,
    this.stadiumCapacity,
    this.foundedYear,
    this.createdAt,
    this.updatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String,
        leagueId: json['leagueId'] as String?,
        leagueName: json['leagueName'] as String?,
        name: json['name'] as String,
        shortName: json['shortName'] as String?,
        logo: json['logo'] as String?,
        country: json['country'] as String?,
        stadium: json['stadium'] as String?,
        stadiumCapacity: json['stadiumCapacity'] as int?,
        foundedYear: json['foundedYear'] as int?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'leagueId': leagueId,
        'leagueName': leagueName,
        'name': name,
        'shortName': shortName,
        'logo': logo,
        'country': country,
        'stadium': stadium,
        'stadiumCapacity': stadiumCapacity,
        'foundedYear': foundedYear,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Team copyWith({
    String? id,
    String? leagueId,
    String? leagueName,
    String? name,
    String? shortName,
    String? logo,
    String? country,
    String? stadium,
    int? stadiumCapacity,
    int? foundedYear,
  }) =>
      Team(
        id: id ?? this.id,
        leagueId: leagueId ?? this.leagueId,
        leagueName: leagueName ?? this.leagueName,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
        logo: logo ?? this.logo,
        country: country ?? this.country,
        stadium: stadium ?? this.stadium,
        stadiumCapacity: stadiumCapacity ?? this.stadiumCapacity,
        foundedYear: foundedYear ?? this.foundedYear,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  bool operator ==(Object other) => other is Team && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Team($name, $country)';
}

/// Team + full squad in one response
class TeamWithPlayers extends Team {
  final List<Player> players;

  const TeamWithPlayers({
    required super.id,
    super.leagueId,
    super.leagueName,
    required super.name,
    super.shortName,
    super.logo,
    super.country,
    super.stadium,
    super.stadiumCapacity,
    super.foundedYear,
    super.createdAt,
    super.updatedAt,
    required this.players,
  });

  factory TeamWithPlayers.fromJson(Map<String, dynamic> json) {
    final base = Team.fromJson(json);
    final playerList = (json['players'] as List<dynamic>? ?? [])
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();
    return TeamWithPlayers(
      id: base.id,
      leagueId: base.leagueId,
      leagueName: base.leagueName,
      name: base.name,
      shortName: base.shortName,
      logo: base.logo,
      country: base.country,
      stadium: base.stadium,
      stadiumCapacity: base.stadiumCapacity,
      foundedYear: base.foundedYear,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      players: playerList,
    );
  }
}

/// Season-aggregated stats matching backend TeamStatsDto
class TeamStats {
  final String id;
  final String teamId;
  final int season;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final int cleanSheets;
  final int failedToScore;
  final String? currentStreak;
  final int? longestWinStreak;
  final int? longestUnbeaten;
  final int? longestLosing;
  final int? totalYellows;
  final int? totalReds;
  final DateTime? updatedAt;

  const TeamStats({
    required this.id,
    required this.teamId,
    required this.season,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
    this.cleanSheets = 0,
    this.failedToScore = 0,
    this.currentStreak,
    this.longestWinStreak,
    this.longestUnbeaten,
    this.longestLosing,
    this.totalYellows,
    this.totalReds,
    this.updatedAt,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  factory TeamStats.fromJson(Map<String, dynamic> json) => TeamStats(
        id: json['id'] as String,
        teamId: json['teamId'] as String,
        season: json['season'] as int,
        played: json['played'] as int? ?? 0,
        wins: json['wins'] as int? ?? 0,
        draws: json['draws'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        goalsFor: json['goalsFor'] as int? ?? 0,
        goalsAgainst: json['goalsAgainst'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
        cleanSheets: json['cleanSheets'] as int? ?? 0,
        failedToScore: json['failedToScore'] as int? ?? 0,
        currentStreak: json['currentStreak'] as String?,
        longestWinStreak: json['longestWinStreak'] as int?,
        longestUnbeaten: json['longestUnbeaten'] as int?,
        longestLosing: json['longestLosing'] as int?,
        totalYellows: json['totalYellows'] as int?,
        totalReds: json['totalReds'] as int?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  String toString() =>
      'TeamStats(season: $season, P$played W$wins D$draws L$losses, pts: $points)';
}
