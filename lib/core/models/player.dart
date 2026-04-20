/// Player model matching backend PlayerDto
class Player {
  final String id;
  final String? teamId;
  final String name;
  final String? shortName;
  final String? nationality;
  final String? position;
  final DateTime? dateOfBirth;
  final int? age;
  final int? heightCm;
  final int? weightKg;
  final int? shirtNumber;
  final String? photoUrl;
  final int appearances;
  final int minutesPlayed;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Player({
    required this.id,
    this.teamId,
    required this.name,
    this.shortName,
    this.nationality,
    this.position,
    this.dateOfBirth,
    this.age,
    this.heightCm,
    this.weightKg,
    this.shirtNumber,
    this.photoUrl,
    this.appearances = 0,
    this.minutesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        teamId: json['teamId'] as String?,
        name: json['name'] as String,
        shortName: json['shortName'] as String?,
        nationality: json['nationality'] as String?,
        position: json['position'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.tryParse(json['dateOfBirth'] as String)
            : null,
        age: json['age'] as int?,
        heightCm: json['heightCm'] as int?,
        weightKg: json['weightKg'] as int?,
        shirtNumber: json['shirtNumber'] as int?,
        photoUrl: json['photoUrl'] as String?,
        appearances: json['appearances'] as int? ?? 0,
        minutesPlayed: json['minutesPlayed'] as int? ?? 0,
        goals: json['goals'] as int? ?? 0,
        assists: json['assists'] as int? ?? 0,
        yellowCards: json['yellowCards'] as int? ?? 0,
        redCards: json['redCards'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'name': name,
        'shortName': shortName,
        'nationality': nationality,
        'position': position,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'shirtNumber': shirtNumber,
        'photoUrl': photoUrl,
        'appearances': appearances,
        'minutesPlayed': minutesPlayed,
        'goals': goals,
        'assists': assists,
        'yellowCards': yellowCards,
        'redCards': redCards,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is Player && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player($name, #$shirtNumber, $position)';
}

/// Detailed player stats from v_player_stats view
class PlayerStats {
  final String playerId;
  final String playerName;
  final String? position;
  final String? nationality;
  final int? age;
  final int? shirtNumber;
  final String? teamName;
  final String? league;
  final int? season;
  final int appearances;
  final int minutesPlayed;
  final int goals;
  final int assists;
  final int goalContributions;
  final int yellowCards;
  final int redCards;
  final double goalsPerGame;
  final double goalsPer90;

  const PlayerStats({
    required this.playerId,
    required this.playerName,
    this.position,
    this.nationality,
    this.age,
    this.shirtNumber,
    this.teamName,
    this.league,
    this.season,
    this.appearances = 0,
    this.minutesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.goalContributions = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.goalsPerGame = 0,
    this.goalsPer90 = 0,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        playerId: json['playerId'] as String,
        playerName: json['playerName'] as String,
        position: json['position'] as String?,
        nationality: json['nationality'] as String?,
        age: json['age'] as int?,
        shirtNumber: json['shirtNumber'] as int?,
        teamName: json['teamName'] as String?,
        league: json['league'] as String?,
        season: json['season'] as int?,
        appearances: json['appearances'] as int? ?? 0,
        minutesPlayed: json['minutesPlayed'] as int? ?? 0,
        goals: json['goals'] as int? ?? 0,
        assists: json['assists'] as int? ?? 0,
        goalContributions: json['goalContributions'] as int? ?? 0,
        yellowCards: json['yellowCards'] as int? ?? 0,
        redCards: json['redCards'] as int? ?? 0,
        goalsPerGame: (json['goalsPerGame'] as num?)?.toDouble() ?? 0,
        goalsPer90: (json['goalsPer90'] as num?)?.toDouble() ?? 0,
      );
}
