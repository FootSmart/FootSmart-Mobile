/// Minimal team reference used inside match responses
class TeamRef {
  final String id;
  final String name;
  final String? shortName;
  final String? logo;

  const TeamRef({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
  });

  factory TeamRef.fromJson(Map<String, dynamic> json) => TeamRef(
        id: json['id'] as String,
        name: json['name'] as String,
        shortName: json['shortName'] as String?,
        logo: json['logo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'logo': logo,
      };
}

/// A single match event (goal, card, substitution…)
class MatchEvent {
  final String id;
  final int? minute;
  final int? extraMinute;
  final String type;
  final String? detail;
  final String? player;
  final String? playerId;
  final String? assistPlayer;
  final String? assistPlayerId;
  final String? teamId;

  const MatchEvent({
    required this.id,
    this.minute,
    this.extraMinute,
    required this.type,
    this.detail,
    this.player,
    this.playerId,
    this.assistPlayer,
    this.assistPlayerId,
    this.teamId,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
        id: json['id'] as String,
        minute: json['minute'] as int?,
        extraMinute: json['extraMinute'] as int?,
        type: json['type'] as String,
        detail: json['detail'] as String?,
        player: json['player'] as String?,
        playerId: json['playerId'] as String?,
        assistPlayer: json['assistPlayer'] as String?,
        assistPlayerId: json['assistPlayerId'] as String?,
        teamId: json['teamId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'minute': minute,
        'extraMinute': extraMinute,
        'type': type,
        'detail': detail,
        'player': player,
        'playerId': playerId,
        'assistPlayer': assistPlayer,
        'assistPlayerId': assistPlayerId,
        'teamId': teamId,
      };
}

/// Full match model matching backend MatchDto
class FootballMatch {
  final String id;
  final String leagueId;
  final String? leagueName;
  final String? leagueCountry;
  final TeamRef homeTeam;
  final TeamRef awayTeam;
  final DateTime? matchDate;
  final String? matchTime;
  final int? matchday;
  final String? venue;
  final int homeGoals;
  final int awayGoals;
  final int? htHomeGoals;
  final int? htAwayGoals;

  /// 'H' | 'D' | 'A'
  final String? result;

  /// 'scheduled' | 'live' | 'finished'
  final String status;
  final DateTime? betClosesAt;
  final bool? isBettingOpen;
  final int? secondsUntilClose;
  final int? minute;
  final String? referee;
  final int? attendance;
  final String? externalId;
  final List<MatchEvent>? events;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FootballMatch({
    required this.id,
    required this.leagueId,
    this.leagueName,
    this.leagueCountry,
    required this.homeTeam,
    required this.awayTeam,
    this.matchDate,
    this.matchTime,
    this.matchday,
    this.venue,
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.htHomeGoals,
    this.htAwayGoals,
    this.result,
    required this.status,
    this.betClosesAt,
    this.isBettingOpen,
    this.secondsUntilClose,
    this.minute,
    this.referee,
    this.attendance,
    this.externalId,
    this.events,
    this.createdAt,
    this.updatedAt,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> json) => FootballMatch(
        id: json['id'] as String,
        leagueId: json['leagueId'] as String,
        leagueName: json['leagueName'] as String?,
        leagueCountry: json['leagueCountry'] as String?,
        homeTeam: TeamRef.fromJson(json['homeTeam'] as Map<String, dynamic>),
        awayTeam: TeamRef.fromJson(json['awayTeam'] as Map<String, dynamic>),
        matchDate: json['matchDate'] != null
            ? DateTime.parse(json['matchDate'] as String)
            : null,
        matchTime: json['matchTime'] as String?,
        matchday: json['matchday'] as int?,
        venue: json['venue'] as String?,
        homeGoals: json['homeGoals'] as int? ?? 0,
        awayGoals: json['awayGoals'] as int? ?? 0,
        htHomeGoals: json['htHomeGoals'] as int?,
        htAwayGoals: json['htAwayGoals'] as int?,
        result: json['result'] as String?,
        status: json['status'] as String? ?? 'scheduled',
        betClosesAt: json['betClosesAt'] != null
          ? DateTime.parse(json['betClosesAt'] as String)
          : null,
        isBettingOpen: json['isBettingOpen'] as bool?,
        secondsUntilClose: (json['secondsUntilClose'] as num?)?.toInt(),
        minute: json['minute'] as int?,
        referee: json['referee'] as String?,
        attendance: json['attendance'] as int?,
        externalId: json['externalId'] as String?,
        events: (json['events'] as List<dynamic>?)
            ?.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
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
        'leagueCountry': leagueCountry,
        'homeTeam': homeTeam.toJson(),
        'awayTeam': awayTeam.toJson(),
        'matchDate': matchDate?.toIso8601String(),
        'matchTime': matchTime,
        'matchday': matchday,
        'venue': venue,
        'homeGoals': homeGoals,
        'awayGoals': awayGoals,
        'htHomeGoals': htHomeGoals,
        'htAwayGoals': htAwayGoals,
        'result': result,
        'status': status,
        'betClosesAt': betClosesAt?.toIso8601String(),
        'isBettingOpen': isBettingOpen,
        'secondsUntilClose': secondsUntilClose,
        'minute': minute,
        'referee': referee,
        'attendance': attendance,
        'externalId': externalId,
        'events': events?.map((e) => e.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  bool get isLive => status == 'live';
  bool get isFinished => status == 'finished';
  bool get isScheduled => status == 'scheduled';

  /// Score string e.g. "2 - 1"
  String get scoreString => '$homeGoals - $awayGoals';
}

/// Paginated wrapper returned by list endpoints
class MatchListResponse {
  final List<FootballMatch> matches;
  final int total;
  final int limit;
  final int offset;

  const MatchListResponse({
    required this.matches,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory MatchListResponse.fromJson(Map<String, dynamic> json) =>
      MatchListResponse(
        matches: (json['matches'] as List<dynamic>)
            .map((m) => FootballMatch.fromJson(m as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
        limit: json['limit'] as int? ?? 20,
        offset: json['offset'] as int? ?? 0,
      );
}

/// Team recent form response
class TeamForm {
  final String teamId;

  /// List of 'W', 'D', 'L'
  final List<String> form;
  final int wins;
  final int draws;
  final int losses;
  final int played;
  final int goalsFor;
  final int goalsAgainst;

  const TeamForm({
    required this.teamId,
    required this.form,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.played,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  factory TeamForm.fromJson(Map<String, dynamic> json) => TeamForm(
        teamId: json['teamId'] as String,
        form: (json['form'] as List<dynamic>).cast<String>(),
        wins: json['wins'] as int? ?? 0,
        draws: json['draws'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        played: json['played'] as int? ?? 0,
        goalsFor: json['goalsFor'] as int? ?? 0,
        goalsAgainst: json['goalsAgainst'] as int? ?? 0,
      );
}
