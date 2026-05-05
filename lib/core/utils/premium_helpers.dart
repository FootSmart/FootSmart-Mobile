import 'package:footsmart_pro/core/constants/revenuecat_constants.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/profile_service.dart';

import '../services/premium_service.dart';

class PremiumHelpers {
  Future<String> _getUserId() async {
    final profileService = ProfileService(ApiService());
    final user = await profileService.getCurrentUser();

    if (user == null) {
      throw Exception('User not found.');
    }

    return user.id;
  }

  Future<void> buyMonthlyPremium() async {
    final premiumService = PremiumService();
    final profileService = ProfileService(ApiService());
    final userId = await _getUserId();

    final offerings = await premiumService.getOfferings(userId: userId);
    final currentOffering = offerings.getOffering(
      RevenueCatConstants.offeringDefault,
    );

    final monthlyPackage = currentOffering?.monthly;

    if (monthlyPackage == null) {
      throw Exception('Monthly package not found.');
    }

    final customerInfo = await premiumService.purchasePackage(
      userId: userId,
      package: monthlyPackage,
    );

    final hasAccess = customerInfo.entitlements.active.containsKey(
      RevenueCatConstants.entitlementPro,
    );

    if (!hasAccess) {
      throw Exception('Purchase finished, but premium access is not active yet.');
    }

    await profileService.getCurrentUserFromDatabase();
  }

  Future<void> buyYearlyPremium() async {
    final premiumService = PremiumService();
    final profileService = ProfileService(ApiService());
    final userId = await _getUserId();

    final offerings = await premiumService.getOfferings(userId: userId);
    final currentOffering = offerings.getOffering(
      RevenueCatConstants.offeringDefault,
    );

    final yearlyPackage = currentOffering?.annual;

    if (yearlyPackage == null) {
      throw Exception('Yearly package not found.');
    }

    final customerInfo = await premiumService.purchasePackage(
      userId: userId,
      package: yearlyPackage,
    );

    final hasAccess = customerInfo.entitlements.active.containsKey(
      RevenueCatConstants.entitlementPro,
    );

    if (!hasAccess) {
      throw Exception('Purchase finished, but premium access is not active yet.');
    }

    await profileService.getCurrentUserFromDatabase();
  }

  Future<bool> restorePremium() async {
    final premiumService = PremiumService();
    final userId = await _getUserId();

    final customerInfo = await premiumService.restorePurchases(userId: userId);

    return customerInfo.entitlements.active.containsKey(
      RevenueCatConstants.entitlementPro,
    );
  }
}