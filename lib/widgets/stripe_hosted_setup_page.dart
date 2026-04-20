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
  String? _webError;

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

  Future<void> _retry() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _webError = null;
    });
    await _controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  static String _prettyWebError(WebResourceError e) {
    final desc = (e.description).trim();
    final code = e.errorCode;
    final type = e.errorType.toString();
    if (desc.isEmpty) {
      return 'Erreur WebView (code $code, $type).';
    }
    return 'Erreur de chargement (code $code): $desc';
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
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _webError = _prettyWebError(error);
            });
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
          if (_webError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF252B3D)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Impossible d’ouvrir Stripe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _webError!,
                        style: const TextStyle(
                          color: Color(0xFFA0A4B8),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Astuce: si vous êtes sur téléphone réel, `10.0.2.2` ne fonctionne pas. '
                        'Utilisez l’IP LAN du PC pour l’API et PUBLIC_BASE_URL côté backend.',
                        style: TextStyle(
                          color: Color(0xFFA0A4B8),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: const Color(0xFF0B1220),
                        ),
                        onPressed: _retry,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen),
            ),
        ],
      ),
    );
  }
}
