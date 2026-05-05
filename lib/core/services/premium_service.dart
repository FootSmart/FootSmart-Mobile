import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/revenuecat_constants.dart';

class PremiumService {
  static bool _configured = false;
  static String? _configuredUserId;

  Future<void> _ensureConfigured(String userId) async {
    // If already configured for same user → do nothing
    if (_configured && _configuredUserId == userId) return;

    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(
      RevenueCatConstants.androidApiKey,
    )..appUserID = userId;

    await Purchases.configure(configuration);

    _configured = true;
    _configuredUserId = userId;

    // Debug (you can remove later)
    // ignore: avoid_print
    print('RevenueCat configured for user: $userId');
  }

  /// Get offerings safely
  Future<Offerings> getOfferings({required String userId}) async {
    await _ensureConfigured(userId);
    return Purchases.getOfferings();
  }

  /// Check premium access safely
  Future<bool> hasPremiumAccess({required String userId}) async {
    await _ensureConfigured(userId);

    final customerInfo = await Purchases.getCustomerInfo();

    return customerInfo.entitlements.active.containsKey(
      RevenueCatConstants.entitlementPro,
    );
  }

  /// Purchase safely
  Future<CustomerInfo> purchasePackage({
    required String userId,
    required Package package,
  }) async {
    await _ensureConfigured(userId);

    final result = await Purchases.purchasePackage(package);
    return result.customerInfo;
  }

  /// Restore safely
  Future<CustomerInfo> restorePurchases({required String userId}) async {
    await _ensureConfigured(userId);
    return Purchases.restorePurchases();
  }
}