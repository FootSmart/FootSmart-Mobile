import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class StripeService {
  StripeService(this._apiService);

  final ApiService _apiService;

  Future<void> addCardWithPaymentSheet() async {
    final res = await _apiService.post(ApiConstants.stripeSetupIntent);
    final data = res.data as Map<String, dynamic>;

    final publishableKey = (data['publishableKey'] ?? '') as String;
    if (publishableKey.isNotEmpty) {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'FootSmart Pro',
        customerId: data['customerId'] as String,
        customerEphemeralKeySecret: data['ephemeralKeySecret'] as String,
        setupIntentClientSecret: data['setupIntentClientSecret'] as String,
        allowsDelayedPaymentMethods: true,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  Future<void> depositWithPaymentSheet({
    required double amount,
    String currency = 'usd',
  }) async {
    final res = await _apiService.post(
      ApiConstants.stripeDepositIntent,
      data: {'amount': amount, 'currency': currency},
    );
    final data = res.data as Map<String, dynamic>;

    final publishableKey = (data['publishableKey'] ?? '') as String;
    if (publishableKey.isNotEmpty) {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'FootSmart Pro',
        paymentIntentClientSecret: data['paymentIntentClientSecret'] as String,
        allowsDelayedPaymentMethods: true,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}

