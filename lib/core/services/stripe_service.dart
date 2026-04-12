import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class StripeService {
  StripeService(this._apiService);

  final ApiService _apiService;

  /// Clé publique : réponse API, sinon `--dart-define=STRIPE_PUBLISHABLE_KEY` (voir main.dart).
  static Future<void> _applyPublishableKey(String? fromApi) async {
    const fromBuild = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
    final key = (fromApi != null && fromApi.trim().isNotEmpty)
        ? fromApi.trim()
        : fromBuild.trim();
    if (key.isEmpty) {
      throw Exception(
        'Clé publique Stripe absente : renseignez STRIPE_PUBLISHABLE_KEY dans le .env du '
        'backend, ou lancez l’app avec --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_…',
      );
    }
    Stripe.publishableKey = key;
    await Stripe.instance.applySettings();
  }

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

  /// Stripe Checkout (page web Stripe) — **recommandé** si l’appareil ne résout pas api.stripe.com.
  Future<String> createHostedSetupCheckoutUrl() async {
    final res = await _apiService.post(ApiConstants.stripeCheckoutSetup);
    final data = res.data as Map<String, dynamic>;
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Impossible d’obtenir l’URL Stripe Checkout.');
    }
    await _applyPublishableKey(data['publishableKey'] as String?);
    return url;
  }

  /// Dépôt wallet : session Checkout **payment** liée au Customer Stripe (choix carte enregistrée).
  Future<String> createHostedDepositCheckoutUrl({
    required double amount,
    String currency = 'usd',
  }) async {
    final res = await _apiService.post(
      ApiConstants.stripeCheckoutDeposit,
      data: {'amount': amount, 'currency': currency},
    );
    final data = res.data as Map<String, dynamic>;
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Impossible d’obtenir l’URL Stripe Checkout (dépôt).');
    }
    await _applyPublishableKey(data['publishableKey'] as String?);
    return url;
  }

  /// Appelle le backend après succès Checkout pour créditer le wallet (webhook souvent absent en local).
  Future<void> completeCheckoutDeposit({required String sessionId}) async {
    await _apiService.post(
      ApiConstants.stripeCompleteCheckoutDeposit,
      data: {'sessionId': sessionId},
    );
  }

  /// Appelé avant d’ouvrir le formulaire carte natif (sans PaymentSheet → pas d’elements/sessions).
  Future<String> prepareAddCardSetupIntent() async {
    final res = await _apiService.post(ApiConstants.stripeSetupIntent);
    final data = res.data as Map<String, dynamic>;
    await _applyPublishableKey(data['publishableKey'] as String?);
    final s = data['setupIntentClientSecret'] as String?;
    if (s == null || s.isEmpty) {
      throw Exception('Réponse API invalide (setupIntentClientSecret).');
    }
    return s;
  }

  /// Après [confirmSetupIntent] réussi dans [StripeCardSheet].
  Future<void> finalizeAddCard(String setupIntentClientSecret) async {
    await _apiService.post(
      ApiConstants.stripeCompleteSetup,
      data: {'setupIntentClientSecret': setupIntentClientSecret},
    );
  }

  /// Prépare un dépôt wallet (sans PaymentSheet).
  Future<String> prepareDepositPaymentIntent({
    required double amount,
    String currency = 'usd',
  }) async {
    final res = await _apiService.post(
      ApiConstants.stripeDepositIntent,
      data: {'amount': amount, 'currency': currency},
    );
    final data = res.data as Map<String, dynamic>;
    await _applyPublishableKey(data['publishableKey'] as String?);
    final s = data['paymentIntentClientSecret'] as String?;
    if (s == null || s.isEmpty) {
      throw Exception('Réponse API invalide (paymentIntentClientSecret).');
    }
    return s;
  }
}
