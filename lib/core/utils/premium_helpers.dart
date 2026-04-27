import 'package:footsmart_pro/core/constants/revenuecat_constants.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/profile_service.dart';

import '../services/premium_service.dart';

class PremiumHelpers {
  Future<void> buyMonthlyPremium() async {
    final premiumService = PremiumService();
    final api = ApiService();
    final profileService = ProfileService(api);

    final offerings = await premiumService.getOfferings();
    final currentOffering = offerings.getOffering('default');

    final monthlyPackage = currentOffering?.monthly;

    if (monthlyPackage == null) {
      throw Exception('Monthly package not found.');
    }

    final customerInfo = await premiumService.purchasePackage(monthlyPackage);

    final hasAccess = customerInfo.entitlements.active.containsKey('pro');

    if (!hasAccess) {
      throw Exception('Purchase finished, but premium access is not active yet.');
    }

    await profileService.getCurrentUserFromDatabase();
    // After this, refresh your backend profile:
    // await profileService.getCurrentUserFromDatabase();
  }

  Future<void> buyYearlyPremium() async {
    final premiumService = PremiumService();

    final offerings = await premiumService.getOfferings();
    final currentOffering = offerings.getOffering('default');

    final yearlyPackage = currentOffering?.annual;

    if (yearlyPackage == null) {
      throw Exception('Yearly package not found.');
    }

    await premiumService.purchasePackage(yearlyPackage);
  }

  Future<bool> restorePremium() async {
    final premiumService = PremiumService();

    final customerInfo = await premiumService.restorePurchases();
    return customerInfo.entitlements.active.containsKey(RevenueCatConstants.entitlementPro);

  }
}