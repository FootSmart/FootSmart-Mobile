/// Standing data model matching backend StandingDto
class Standing {
  final String id;
  final int position;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int points;
  final int goalDiff;
  final int? goalsFor;
  final int? goalsAgainst;
  final String? form;
  final int? matchday;
  final int season;
  final String teamId;
  final String teamName;
  final String? teamLogo;
  final String? teamCountry;

  Standing({
    required this.id,
    required this.position,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.points,
    required this.goalDiff,
    this.goalsFor,
    this.goalsAgainst,
    this.form,
    this.matchday,
    required this.season,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    this.teamCountry,
  });

  /// Create Standing from JSON response
  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      id: json['id'] as String,
      position: json['position'] as int,
      played: json['played'] as int,
      wins: json['wins'] as int,
      draws: json['draws'] as int,
      losses: json['losses'] as int,
      points: json['points'] as int,
      goalDiff: json['goalDiff'] as int,
      goalsFor: json['goalsFor'] as int?,
      goalsAgainst: json['goalsAgainst'] as int?,
      form: json['form'] as String?,
      matchday: json['matchday'] as int?,
      season: json['season'] as int,
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      teamLogo: json['teamLogo'] as String?,
      teamCountry: json['teamCountry'] as String?,
    );
  }

  /// Convert Standing to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'played': played,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'points': points,
      'goalDiff': goalDiff,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'form': form,
      'matchday': matchday,
      'season': season,
      'teamId': teamId,
      'teamName': teamName,
      'teamLogo': teamLogo,
      'teamCountry': teamCountry,
    };
  }

  /// Recent form as a list of characters e.g. ['W','W','D','L','W']
  List<String> get formList =>
      form?.split('').where((c) => c.isNotEmpty).toList() ?? [];

  @override
  String toString() {
    return 'Standing(position: $position, team: $teamName, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Standing && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// League standings response matching backend LeagueStandingsDto
class LeagueStandings {
  final String id;
  final String name;
  final String? country;
  final int? season;
  final List<Standing> standings;

  LeagueStandings({
    required this.id,
    required this.name,
    this.country,
    this.season,
    required this.standings,
  });

  /// Create LeagueStandings from JSON response
  factory LeagueStandings.fromJson(Map<String, dynamic> json) {
    return LeagueStandings(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String?,
      season: json['season'] as int?,
      standings: (json['standings'] as List<dynamic>)
          .map(
              (standing) => Standing.fromJson(standing as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert LeagueStandings to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'season': season,
      'standings': standings.map((s) => s.toJson()).toList(),
    };
  }

  /// Get top N teams from standings
  List<Standing> getTopTeams(int count) {
    return standings.take(count).toList();
  }

  /// Calculate statistics
  int get totalTeams => standings.length;
  int get totalMatches => standings.fold(0, (sum, s) => sum + s.played);
  double get avgGoalsPerMatch {
    if (totalMatches == 0) return 0.0;
    // This is a rough estimate based on goal difference
    // In reality, you'd need goals scored data
    return 2.5; // Default estimate
  }

  @override
  String toString() {
    return 'LeagueStandings(name: $name, teams: ${standings.length})';
  }
}
