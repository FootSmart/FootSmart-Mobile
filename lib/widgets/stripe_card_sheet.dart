import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../core/constants/app_colors.dart';

/// Mode test / prod : collecte carte sans PaymentSheet (évite GET …/elements/sessions).
enum StripeCardSheetMode { setupIntent, paymentIntent }

/// Réseau / DNS (émulateur, VPN, pas de Wi‑Fi) — le code ne peut pas « réparer » la résolution DNS.
String _stripeErrorForUser(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('unable to resolve host') ||
      lower.contains('no address associated with hostname') ||
      (lower.contains('ioexception') && lower.contains('api.stripe.com'))) {
    return 'Réseau / DNS : impossible de joindre api.stripe.com.\n\n'
        '• Vérifiez le Wi‑Fi ou les données mobiles.\n'
        '• Émulateur : redémarrage à froid, image avec Google Play, ou testez sur un téléphone réel.\n'
        '• Désactivez VPN / pare-feu / « Private DNS » bloquant.\n'
        '• Ouvrez un navigateur sur l’appareil : si https://stripe.com ne charge pas, le problème vient du réseau local.';
  }
  if (lower.contains('sockettimeout') ||
      lower.contains('timed out') ||
      lower.contains('connection refused')) {
    return 'Connexion trop lente ou refusée. Réessayez avec un meilleur réseau.\n\n$raw';
  }
  return raw;
}

bool _isLikelyNetworkError(String? displayed) {
  if (displayed == null) return false;
  final l = displayed.toLowerCase();
  return l.contains('réseau / dns') ||
      l.contains('api.stripe.com') ||
      l.contains('unable to resolve') ||
      l.contains('ioexception');
}

/// Feuille modale : [CardField] + confirmation — état **dynamique** (bouton selon saisie).
class StripeCardSheet extends StatefulWidget {
  const StripeCardSheet({
    super.key,
    required this.mode,
    required this.clientSecret,
    required this.title,
    this.subtitle,
    this.confirmLabel = 'Valider',
  });

  final StripeCardSheetMode mode;
  final String clientSecret;
  final String title;
  final String? subtitle;
  final String confirmLabel;

  @override
  State<StripeCardSheet> createState() => _StripeCardSheetState();
}

class _StripeCardSheetState extends State<StripeCardSheet> {
  bool _busy = false;
  String? _error;
  bool _cardComplete = false;

  Future<void> _submit() async {
    if (!_cardComplete || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.mode == StripeCardSheetMode.setupIntent) {
        await Stripe.instance.confirmSetupIntent(
          paymentIntentClientSecret: widget.clientSecret,
          params: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
      } else {
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: widget.clientSecret,
          data: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        if (mounted) Navigator.of(context).pop(false);
        return;
      }
      final msg = e.error.localizedMessage ?? e.toString();
      setState(() => _error = _stripeErrorForUser(msg));
    } catch (e) {
      setState(() => _error = _stripeErrorForUser(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryDark : scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _busy ? null : () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _cardComplete
                        ? 'Carte complète — vous pouvez valider.'
                        : 'Saisissez le numéro, la date et le CVC.',
                    key: ValueKey<bool>(_cardComplete),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _cardComplete
                          ? AppColors.accentGreen.withValues(alpha: 0.95)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: CardField(
                    onCardChanged: (details) {
                      final ok = details?.complete ?? false;
                      if (ok != _cardComplete) {
                        setState(() {
                          _cardComplete = ok;
                          _error = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest.withValues(
                        alpha: isDark ? 0.35 : 0.65,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.accentGreen,
                          width: 1.5,
                        ),
                      ),
                      labelText: 'Numéro de carte',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    cursorColor: AppColors.accentGreen,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: scheme.error,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if (_isLikelyNetworkError(_error)) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _busy || !_cardComplete
                            ? null
                            : () {
                                setState(() => _error = null);
                                _submit();
                              },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Réessayer'),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: _cardComplete && !_busy
                        ? AppColors.accentGreen
                        : scheme.surfaceContainerHighest,
                    foregroundColor: _cardComplete && !_busy
                        ? AppColors.primaryDark
                        : scheme.onSurfaceVariant,
                  ),
                  onPressed:
                      (_busy || !_cardComplete) ? null : _submit,
                  child: _busy
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onSurface,
                          ),
                        )
                      : Text(widget.confirmLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
