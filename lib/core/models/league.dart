/// League data model matching backend LeagueDto
class League {
  final String id;
  final String name;
  final String? country;
  final int? season;
  final DateTime? createdAt;

  League({
    required this.id,
    required this.name,
    this.country,
    this.season,
    this.createdAt,
  });

  /// Create League from JSON response
  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String?,
      season: json['season'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert League to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'season': season,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with optional field updates
  League copyWith({
    String? id,
    String? name,
    String? country,
    int? season,
    DateTime? createdAt,
  }) {
    return League(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      season: season ?? this.season,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'League(id: $id, name: $name, country: $country, season: $season)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is League && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
