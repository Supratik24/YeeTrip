import 'package:url_launcher/url_launcher.dart';
import '../../../../core/money.dart';

/// Helper utility for creating and launching NPCI-compliant UPI payment intents.
class UpiPaymentLauncher {
  UpiPaymentLauncher._();

  /// Constructs a valid NPCI UPI payment deep-link URI.
  ///
  /// Parameters:
  /// - [payeeVpa]: Payee Virtual Payment Address (e.g., `name@okhdfcbank`)
  /// - [payeeName]: Payee display name
  /// - [amountPaise]: Settlement amount strictly in integer paise
  /// - [note]: Optional transaction description/memo
  static Uri buildUpiUri({
    required String payeeVpa,
    required String payeeName,
    required int amountPaise,
    String? note,
  }) {
    final amountDecimal = Money.paiseToDecimalString(amountPaise);
    final cleanNote = note?.trim() ?? 'YeeTrip Settlement';

    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': payeeVpa.trim(),
        'pn': payeeName.trim(),
        'am': amountDecimal,
        'cu': 'INR',
        'tn': cleanNote,
      },
    );
  }

  /// Attempts to launch the UPI payment intent via the platform's registered UPI app
  /// (e.g., Google Pay, PhonePe, Paytm, BHIM).
  ///
  /// Returns `true` if launched successfully, or `false` if no UPI application is available.
  static Future<bool> launchUpiPayment({
    required String payeeVpa,
    required String payeeName,
    required int amountPaise,
    String? note,
  }) async {
    final uri = buildUpiUri(
      payeeVpa: payeeVpa,
      payeeName: payeeName,
      amountPaise: amountPaise,
      note: note,
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      // In case platform cannot handle the custom scheme
      return false;
    }
    return false;
  }
}
