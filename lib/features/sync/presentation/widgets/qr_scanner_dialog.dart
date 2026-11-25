import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR code scanner dialog for joining shared YeeTrip rooms.
/// Supports both live camera scanning and importing a QR screenshot from gallery.
class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  /// Opens the QR scanner dialog and returns a formatted invite code
  /// (e.g. `ABC-123`) if scanned, or `null` if cancelled.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const QrScannerDialog(),
    );
  }

  /// Extracts a normalized `ABC-123` invite code from raw QR payload text
  /// (supports `yeetrip://join?code=ABC-123`, `ABC-123`, or `ABC123`).
  static String? extractInviteCode(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return null;

    String candidate = trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.queryParameters.containsKey('code')) {
      candidate = uri.queryParameters['code'] ?? trimmed;
    }

    final clean = candidate.trim().toUpperCase().replaceAll(' ', '');
    if (RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$').hasMatch(clean)) {
      return clean;
    }
    if (RegExp(r'^[A-Z0-9]{6}$').hasMatch(clean)) {
      return '${clean.substring(0, 3)}-${clean.substring(3)}';
    }
    return null;
  }

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBarcodeCapture(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final code = QrScannerDialog.extractInviteCode(raw);
      if (code != null) {
        _handled = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;

      final capture = await _controller.analyzeImage(picked.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        for (final b in capture.barcodes) {
          final code =
              b.rawValue != null ? QrScannerDialog.extractInviteCode(b.rawValue!) : null;
          if (code != null && mounted) {
            _handled = true;
            Navigator.of(context).pop(code);
            return;
          }
        }
      }

      if (mounted) {
        setState(() {
          _errorText = 'No valid YeeTrip invite QR code found in image.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = 'Could not read QR from image: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onBarcodeCapture,
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Camera unavailable (${error.errorCode.name}). You can still import a QR screenshot from Gallery below.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top AppBar Overlay
            Positioned(
              left: 8,
              right: 8,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Scan Trip Invite QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    tooltip: 'Toggle flash',
                    onPressed: _controller.toggleTorch,
                  ),
                ],
              ),
            ),

            // Center Target Frame
            Center(
              child: IgnorePointer(
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Gallery Pick & Status
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorText != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  FilledButton.icon(
                    key: const Key('scan_qr_from_gallery_btn'),
                    onPressed: _scanFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Scan QR from Gallery'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
