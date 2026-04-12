/// Wallet balance model
class WalletBalance {
  final double balance;
  final String currency;

  WalletBalance({
    required this.balance,
    required this.currency,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // Parse balance - handle both string and number formats
    double parseBalance(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0;
    }

    return WalletBalance(
      balance: parseBalance(json['balance']),
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
    };
  }
}

/// Transaction type enum
enum WalletTransactionType {
  deposit,
  withdraw,
  bet,
  win;

  String toJson() => name;

  static WalletTransactionType fromJson(String value) {
    return values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => WalletTransactionType.deposit,
    );
  }
}

/// Wallet transaction model
class WalletTransaction {
  final String id;
  final String userId;
  final WalletTransactionType type;
  final double amount;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    // Parse amount - handle both string and number formats
    double parseAmount(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0;
    }

    return WalletTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: WalletTransactionType.fromJson(json['type'] as String),
      amount: parseAmount(json['amount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toJson(),
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPositive =>
      type == WalletTransactionType.deposit ||
      type == WalletTransactionType.win;
  bool get isNegative =>
      type == WalletTransactionType.withdraw ||
      type == WalletTransactionType.bet;
}

/// Transactions list response model
class TransactionsResponse {
  final List<WalletTransaction> transactions;
  final int total;
  final int limit;
  final int offset;

  TransactionsResponse({
    required this.transactions,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    final raw = json['transactions'];
    final list = raw is List<dynamic> ? raw : <dynamic>[];

    return TransactionsResponse(
      transactions: list
          .map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      total: asInt(json['total']),
      limit: asInt(json['limit'], 50),
      offset: asInt(json['offset']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}

/// Deposit/Withdraw response model
class TransactionResult {
  final bool success;
  final TransactionDetail transaction;

  TransactionResult({
    required this.success,
    required this.transaction,
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    return TransactionResult(
      success: json['success'] as bool,
      transaction: TransactionDetail.fromJson(
          json['transaction'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transaction': transaction.toJson(),
    };
  }
}

/// Transaction detail model
class TransactionDetail {
  final String id;
  final String type;
  final double amount;
  final double newBalance;
  final DateTime createdAt;

  TransactionDetail({
    required this.id,
    required this.type,
    required this.amount,
    required this.newBalance,
    required this.createdAt,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    // Parse amount - handle both string and number formats
    double parseAmount(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0;
    }

    return TransactionDetail(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: parseAmount(json['amount']),
      newBalance: parseAmount(json['newBalance']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'newBalance': newBalance,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
