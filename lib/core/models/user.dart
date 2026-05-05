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
  final String? kycProvider;
  final String? kycVerifiedAt;
  final String? kycRejectionReason;
  final double balance;
  final bool subscriptionActive;
  final String? subscriptionPlan;
  final DateTime? subscriptionEndsAt;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) {
      return value != 0; // 1 = true, 0 = false
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes';
    }
    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      if (value.trim().isEmpty) return null;

      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

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
    this.accountStatus = 'inactive',
    this.kycProvider,
    this.kycVerifiedAt,
    this.kycRejectionReason,
    this.balance = 0.0,
    this.subscriptionActive = false,
    this.subscriptionPlan,
    this.subscriptionEndsAt,
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

  /// Helper for UI/paywall checks
  bool get hasPremiumAccess {
    if (!subscriptionActive) return false;

    if (subscriptionEndsAt == null) return true;

    return subscriptionEndsAt!.isAfter(DateTime.now());
  }

  /// Optional helper for display
  bool get isSubscriptionExpired {
    if (subscriptionEndsAt == null) return false;
    return subscriptionEndsAt!.isBefore(DateTime.now());
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? country,
    String? club,
    String? avatarUrl,
    String? dateOfBirth,
    String? phoneNumber,
    String? kycStatus,
    String? accountStatus,
    double? balance,
    bool? subscriptionActive,
    String? subscriptionPlan,
    DateTime? subscriptionEndsAt,
    bool clearSubscriptionPlan = false,
    bool clearSubscriptionEndsAt = false,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      country: country ?? this.country,
      club: club ?? this.club,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      kycStatus: kycStatus ?? this.kycStatus,
      accountStatus: accountStatus ?? this.accountStatus,
      balance: balance ?? this.balance,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      subscriptionPlan: clearSubscriptionPlan
          ? null
          : (subscriptionPlan ?? this.subscriptionPlan),
      subscriptionEndsAt: clearSubscriptionEndsAt
          ? null
          : (subscriptionEndsAt ?? this.subscriptionEndsAt),
    );
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
      accountStatus: json['accountStatus'] as String? ?? 'inactive',
      kycProvider: json['kycProvider'] as String? ?? json['provider'] as String?,
      kycVerifiedAt: json['kycVerifiedAt'] as String? ?? json['verifiedAt'] as String?,
      kycRejectionReason: json['kycRejectionReason'] as String? ??
          json['rejectionReason'] as String?,
      balance: _parseDouble(json['balance']),
      // NEW: accept both camelCase and snake_case
      subscriptionActive: _parseBool(
        json['subscriptionActive'] ?? json['subscription_active'],
      ),
      subscriptionPlan: (json['subscriptionPlan'] ?? json['subscription_plan']) as String?,
      subscriptionEndsAt: _parseDateTime(
        json['subscriptionEndsAt'] ?? json['subscription_ends_at'],
      ),
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
      'kycProvider': kycProvider,
      'kycVerifiedAt': kycVerifiedAt,
      'kycRejectionReason': kycRejectionReason,
      'balance': balance,
      // new subscription
      'subscriptionActive': subscriptionActive,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionEndsAt': subscriptionEndsAt?.toIso8601String(),
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
  final String? nextStep;

  AuthResponse({
    required this.accessToken,
    required this.user,
    this.nextStep,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      nextStep: json['next_step'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user': user.toJson(),
      'next_step': nextStep,
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
