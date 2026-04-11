import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class StripeService {
  StripeService(this._apiService);

  final ApiService _apiService;

  /// Cartes enregistrées côté Stripe pour l’utilisateur connecté (JWT).
  Future<List<Map<String, dynamic>>> fetchPaymentMethods() async {
    final res = await _apiService.get(ApiConstants.stripePaymentMethods);
    final data = res.data as Map<String, dynamic>;
    final list = data['paymentMethods'];
    if (list is! List) return [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// Retourne `true` si la carte est enregistrée, `false` si l’utilisateur a fermé / annulé le flux.
  Future<bool> addCardWithPaymentSheet() async {
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

    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      rethrow;
    }
  }

  /// Retourne `true` si le paiement est terminé, `false` si annulé par l’utilisateur.
  Future<bool> depositWithPaymentSheet({
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

    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      rethrow;
    }
  }
}

