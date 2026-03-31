class User {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? country;
  final String? club;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String kycStatus;
  final String accountStatus;
  final double balance;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.country,
    this.club,
    this.avatarUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.kycStatus = 'not_started',
    this.accountStatus = 'active',
    this.balance = 0.0,
  });

  /// Get user initials for avatar
  String get initials {
    final names = displayName.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names.first[0].toUpperCase();
    return (names.first[0] + names.last[0]).toUpperCase();
  }

  /// Get first name from display name
  String get firstName => displayName.split(' ').first;

  /// Get last name from display name
  String get lastName {
    final parts = displayName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      country: json['country'] as String?,
      club: json['club'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      kycStatus: json['kycStatus'] as String? ?? 'not_started',
      accountStatus: json['accountStatus'] as String? ?? 'active',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'country': country,
      'club': club,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'kycStatus': kycStatus,
      'accountStatus': accountStatus,
      'balance': balance,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String displayName;
  final String dateOfBirth; // Format: YYYY-MM-DD
  final String role; // 'player' or 'coach'
  final String? country;
  final String? club;
  final String? avatarUrl;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
    required this.dateOfBirth,
    required this.role,
    this.country,
    this.club,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'email': email,
      'password': password,
      'displayName': displayName,
      'dateOfBirth': dateOfBirth,
      'role': role,
    };
    if (country != null) map['country'] = country!;
    if (club != null) map['club'] = club!;
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl!;
    return map;
  }
}

class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user': user.toJson(),
    };
  }
}

class UserStats {
  final int totalBets;
  final double winRate;
  final double totalWon;
  final double roi;
  final int wins;
  final int losses;
  final double totalStaked;
  final DateTime? memberSince;

  UserStats({
    required this.totalBets,
    required this.winRate,
    required this.totalWon,
    required this.roi,
    required this.wins,
    required this.losses,
    required this.totalStaked,
    this.memberSince,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalBets: json['totalBets'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      totalWon: (json['totalWon'] as num?)?.toDouble() ?? 0.0,
      roi: (json['roi'] as num?)?.toDouble() ?? 0.0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      totalStaked: (json['totalStaked'] as num?)?.toDouble() ?? 0.0,
      memberSince: json['memberSince'] != null
          ? DateTime.tryParse(json['memberSince'] as String)
          : null,
    );
  }
}
