import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/constants/app_colors.dart';

/// Ouvre la page **Stripe Checkout** (setup ou paiement) : la page est servie par Stripe,
/// pas le SDK natif — évite les erreurs DNS vers `api.stripe.com` sur l’appareil.
///
/// [returnUrlContains] doit correspondre au segment d’URL de retour du backend (`hosted-setup-return`,
/// `hosted-deposit-return`, etc.).
class StripeHostedSetupPage extends StatefulWidget {
  const StripeHostedSetupPage({
    super.key,
    required this.initialUrl,
    this.returnUrlContains = 'hosted-setup-return',
    this.appBarTitle = 'Carte sécurisée (Stripe)',
  });

  final String initialUrl;
  final String returnUrlContains;
  final String appBarTitle;

  @override
  State<StripeHostedSetupPage> createState() => _StripeHostedSetupPageState();
}

class _StripeHostedSetupPageState extends State<StripeHostedSetupPage> {
  late final WebViewController _controller;
  var _loading = true;
  var _didFinish = false;

  bool _isReturnUrl(String url) => url.contains(widget.returnUrlContains);

  void _tryFinishFromUrl(String url) {
    if (_didFinish || !mounted || !_isReturnUrl(url)) return;
    final uri = Uri.parse(url);
    if (uri.queryParameters['canceled'] == '1') {
      _didFinish = true;
      Navigator.of(context).pop<String?>(null);
      return;
    }
    if (uri.queryParameters.containsKey('session_id')) {
      _didFinish = true;
      Navigator.of(context).pop<String?>(uri.queryParameters['session_id']);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.primaryDark)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            _tryFinishFromUrl(request.url);
            if (_isReturnUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _loading = false);
            _tryFinishFromUrl(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop<String?>(null),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen),
            ),
        ],
      ),
    );
  }
}
