import '../models/wallet.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Service for handling wallet-related API calls
class WalletService {
  final ApiService _apiService;

  WalletService(this._apiService);

  /// Get current user's wallet balance
  ///
  /// Returns [WalletBalance] with current balance and currency
  /// Throws [ApiException] on error
  Future<WalletBalance> getBalance() async {
    try {
      final response = await _apiService.get(ApiConstants.walletBalance);

      if (response.statusCode == 200) {
        return WalletBalance.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to fetch balance');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch balance: ${e.toString()}');
    }
  }

  /// Get available points packs
  Future<List<PointsPack>> getPointsPacks() async {
    try {
      final response = await _apiService.get(ApiConstants.pointsPacks);

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((p) => PointsPack.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException('Failed to fetch points packs');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch points packs: ${e.toString()}');
    }
  }

  /// Buy a points pack via Stripe Checkout
  Future<String> buyPointsPack(
      {required String packId, String currency = 'usd'}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.buyPointsPack,
        data: {'packId': packId, 'currency': currency},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final url = data['url'] as String?;
        if (url == null || url.isEmpty) {
          throw ApiException('Failed to get checkout URL');
        }
        return url;
      } else {
        throw ApiException('Failed to buy points pack');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to buy points pack: ${e.toString()}');
    }
  }

  /// Complete points pack purchase after Stripe return
  Future<int> completePointsPackPurchase(String sessionId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.completePointsPack,
        data: {'sessionId': sessionId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return data['newPoints'] as int? ?? 0;
      } else {
        throw ApiException('Failed to complete purchase');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to complete purchase: ${e.toString()}');
    }
  }

  /// Get all wallet transactions
  ///
  /// [limit] - Maximum number of transactions to retrieve (default: 50)
  /// [offset] - Number of transactions to skip (default: 0)
  ///
  /// Returns [TransactionsResponse] with list of transactions and pagination info
  /// Throws [ApiException] on error
  Future<TransactionsResponse> getTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.walletTransactions,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        return TransactionsResponse.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to fetch transactions');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch transactions: ${e.toString()}');
    }
  }

  /// Deposit money to wallet
  ///
  /// [amount] - Amount to deposit (must be positive)
  ///
  /// Returns [TransactionResult] with transaction details and new balance
  /// Throws [ApiException] on error or invalid amount
  Future<TransactionResult> deposit(double amount) async {
    if (amount <= 0) {
      throw ApiException('Deposit amount must be positive');
    }

    try {
      final response = await _apiService.post(
        ApiConstants.walletDeposit,
        data: {'amount': amount},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TransactionResult.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to deposit funds');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to deposit funds: ${e.toString()}');
    }
  }

  /// Withdraw money from wallet
  ///
  /// [amount] - Amount to withdraw (must be positive and <= balance)
  ///
  /// Returns [TransactionResult] with transaction details and new balance
  /// Throws [ApiException] on error, invalid amount, or insufficient balance
  Future<TransactionResult> withdraw(double amount) async {
    if (amount <= 0) {
      throw ApiException('Withdrawal amount must be positive');
    }

    try {
      final response = await _apiService.post(
        ApiConstants.walletWithdraw,
        data: {'amount': amount},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TransactionResult.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to withdraw funds');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to withdraw funds: ${e.toString()}');
    }
  }
}
