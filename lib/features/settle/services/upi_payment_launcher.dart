import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/money.dart';

/// Supported Indian UPI applications for dedicated direct payments.
enum UpiApp {
  googlePay(
    label: 'Google Pay',
    subtitle: 'Open GPay app directly',
    scheme: 'tez',
    host: 'upi',
    accentColor: Color(0xFF1A73E8),
    icon: Icons.g_mobiledata_rounded,
  ),
  phonePe(
    label: 'PhonePe',
    subtitle: 'Open PhonePe app directly',
    scheme: 'phonepe',
    host: 'pay',
    accentColor: Color(0xFF5F259F),
    icon: Icons.account_balance_wallet_outlined,
  ),
  paytm(
    label: 'Paytm',
    subtitle: 'Open Paytm app directly',
    scheme: 'paytmmp',
    host: 'pay',
    accentColor: Color(0xFF00BAF2),
    icon: Icons.payments_outlined,
  ),
  bhim(
    label: 'BHIM / Other UPI',
    subtitle: 'Choose from any installed UPI app',
    scheme: 'upi',
    host: 'pay',
    accentColor: Color(0xFF0F766E),
    icon: Icons.account_balance_outlined,
  );

  final String label;
  final String subtitle;
  final String scheme;
  final String host;
  final Color accentColor;
  final IconData icon;

  const UpiApp({
    required this.label,
    required this.subtitle,
    required this.scheme,
    required this.host,
    required this.accentColor,
    required this.icon,
  });
}

/// Helper utility for creating and launching NPCI-compliant UPI payment intents.
class UpiPaymentLauncher {
  UpiPaymentLauncher._();

  /// Constructs a valid NPCI UPI payment deep-link URI for [app].
  ///
  /// Parameters:
  /// - [payeeVpa]: Payee Virtual Payment Address (e.g., `name@okhdfcbank`)
  /// - [payeeName]: Payee display name
  /// - [amountPaise]: Settlement amount strictly in integer paise
  /// - [note]: Optional transaction description/memo
  /// - [app]: Target UPI app scheme (defaults to standard `upi://pay`)
  static Uri buildUpiUri({
    required String payeeVpa,
    required String payeeName,
    required int amountPaise,
    String? note,
    UpiApp app = UpiApp.bhim,
  }) {
    final amountDecimal = Money.paiseToDecimalString(amountPaise);
    final cleanNote = note?.trim() ?? 'YeeTrip Settlement';

    return Uri(
      scheme: app.scheme,
      host: app.host,
      path: app == UpiApp.googlePay ? '/pay' : null,
      queryParameters: {
        'pa': payeeVpa.trim(),
        'pn': payeeName.trim(),
        'am': amountDecimal,
        'cu': 'INR',
        'tn': cleanNote,
      },
    );
  }

  /// Attempts to launch the UPI payment intent via the selected [app],
  /// automatically falling back to generic `upi://pay` if the app-specific
  /// custom scheme is unavailable on the device.
  ///
  /// Returns `true` if launched successfully, or `false` if no UPI app can handle it.
  static Future<bool> launchUpiPayment({
    required String payeeVpa,
    required String payeeName,
    required int amountPaise,
    String? note,
    UpiApp app = UpiApp.bhim,
  }) async {
    final preferredUri = buildUpiUri(
      payeeVpa: payeeVpa,
      payeeName: payeeName,
      amountPaise: amountPaise,
      note: note,
      app: app,
    );

    try {
      if (await canLaunchUrl(preferredUri)) {
        final ok = await launchUrl(
          preferredUri,
          mode: LaunchMode.externalApplication,
        );
        if (ok) return true;
      }

      if (app != UpiApp.bhim) {
        final fallbackUri = buildUpiUri(
          payeeVpa: payeeVpa,
          payeeName: payeeName,
          amountPaise: amountPaise,
          note: note,
          app: UpiApp.bhim,
        );
        if (await canLaunchUrl(fallbackUri)) {
          return await launchUrl(
            fallbackUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
