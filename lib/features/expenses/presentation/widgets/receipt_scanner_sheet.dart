import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/gemini_receipt_scanner_service.dart';
import '../../../../core/money.dart';
import '../../../../core/receipt_parser.dart';
import '../../../../core/receipt_scanner_service.dart';
import '../../../../core/services/local_image_store.dart';

/// Supported OCR engines for bill scanning.
enum OcrEngine {
  onDevice,
  geminiVision,
}

/// Modal bottom sheet that enables scanning, pasting, and previewing physical receipts
/// with dual-engine support (On-Device Fast OCR + Google Gemini Vision AI).
class ReceiptScannerSheet extends ConsumerStatefulWidget {
  final ValueChanged<ReceiptData> onReceiptApplied;

  const ReceiptScannerSheet({
    super.key,
    required this.onReceiptApplied,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<ReceiptData> onReceiptApplied,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptScannerSheet(onReceiptApplied: onReceiptApplied),
    );
  }

  @override
  ConsumerState<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends ConsumerState<ReceiptScannerSheet> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();

  OcrEngine _selectedEngine = OcrEngine.onDevice;
  ReceiptData? _parsedReceipt;
  String? _scannedImagePath;
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parseCurrentText(String text, {bool clearImage = true}) {
    if (clearImage) {
      _scannedImagePath = null;
    }
    if (text.trim().isEmpty) {
      setState(() {
        _parsedReceipt = null;
        _statusMessage = null;
      });
      return;
    }

    final service = ref.read(receiptScannerServiceProvider);
    final parsed = service.parseText(text).copyWith(
      imagePath: _scannedImagePath,
    );

    setState(() {
      _parsedReceipt = parsed;
      if (parsed.amountPaise != null && parsed.amountPaise! > 0) {
        _statusMessage = 'Extracted: ${Money.formatRupees(parsed.amountPaise!)}';
      } else {
        _statusMessage = 'Could not find a valid total amount in text.';
      }
    });
  }

  void _loadSample(SampleReceipt sample) {
    _textController.text = sample.rawText;
    _parseCurrentText(sample.rawText);
  }

  Future<void> _pickImage(ImageSource source) async {
    // If Gemini Vision is selected, check for API key
    if (_selectedEngine == OcrEngine.geminiVision) {
      final hasKey = ref.read(geminiReceiptScannerServiceProvider).hasApiKey;
      if (!hasKey) {
        final keySaved = await _showApiKeyDialog();
        if (!keySaved) {
          setState(() {
            _statusMessage = 'Gemini API key is required to use AI Bill Scanner.';
          });
          return;
        }
      }
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Opening ${source == ImageSource.camera ? "camera" : "gallery"}...';
    });

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (file == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Image selection cancelled.';
        });
        return;
      }

      final persistedPath = await LocalImageStore.persistImage(
        file.path,
        folder: 'receipts',
      );
      _scannedImagePath = persistedPath;

      if (_selectedEngine == OcrEngine.geminiVision) {
        setState(() {
          _statusMessage = 'Analyzing bill with Gemini Vision AI model...';
        });

        final geminiService = ref.read(geminiReceiptScannerServiceProvider);
        final receiptData = (await geminiService.scanReceiptImage(persistedPath))
            .copyWith(imagePath: persistedPath);

        setState(() {
          _parsedReceipt = receiptData;
          _textController.text = receiptData.rawText;
          if (receiptData.amountPaise != null) {
            _statusMessage = '✨ AI Extracted: ${Money.formatRupees(receiptData.amountPaise!)}';
          } else {
            _statusMessage = 'AI analyzed bill, but total amount was unclear.';
          }
        });
      } else {
        setState(() {
          _statusMessage = 'Scanning bill with On-Device OCR...';
        });

        final service = ref.read(receiptScannerServiceProvider);
        final recognizedText = await service.recognizeTextFromImage(persistedPath);

        if (recognizedText.trim().isNotEmpty) {
          _textController.text = recognizedText.trim();
          _parseCurrentText(recognizedText.trim(), clearImage: false);
        } else {
          setState(() {
            _statusMessage =
                'Could not detect clear text from this photo. Ensure the bill is well-lit and in focus, or try Gemini Vision AI mode.';
          });
        }
      }
    } on GeminiReceiptException catch (ge) {
      setState(() {
        _statusMessage = ge.message;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error scanning bill: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showApiKeyDialog() async {
    final controller = TextEditingController(
      text: ref.read(geminiApiKeyProvider) ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 8),
            Text('Gemini Vision API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini Vision AI provides state-of-the-art receipt recognition (99%+ accuracy for complex & thermal bills).',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Google Gemini API Key',
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get a 100% free API key at:\naistudio.google.com',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                ref.read(geminiApiKeyProvider.notifier).setKey(key);
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Save Key'),
          ),
        ],
      ),
    );

    return saved ?? false;
  }

  void _applyReceipt() {
    if (_parsedReceipt == null || _parsedReceipt!.amountPaise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or paste a receipt with a valid total amount.'),
        ),
      );
      return;
    }

    widget.onReceiptApplied(
      _scannedImagePath != null
          ? _parsedReceipt!.copyWith(imagePath: _scannedImagePath)
          : _parsedReceipt!,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final samples = ref.read(receiptScannerServiceProvider).getSampleReceipts();
    final hasGeminiKey = ref.watch(geminiReceiptScannerServiceProvider).hasApiKey;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.document_scanner, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Scan Bill / Receipt',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Engine Selector
                    SegmentedButton<OcrEngine>(
                      segments: const [
                        ButtonSegment<OcrEngine>(
                          value: OcrEngine.onDevice,
                          icon: Icon(Icons.flash_on, size: 16),
                          label: Text('On-Device OCR'),
                        ),
                        ButtonSegment<OcrEngine>(
                          value: OcrEngine.geminiVision,
                          icon: Icon(Icons.auto_awesome, size: 16),
                          label: Text('Gemini Vision AI'),
                        ),
                      ],
                      selected: {_selectedEngine},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedEngine = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Gemini Key Info Banner (if Gemini selected)
                    if (_selectedEngine == OcrEngine.geminiVision) ...[
                      InkWell(
                        onTap: _showApiKeyDialog,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasGeminiKey
                                ? Colors.teal.withValues(alpha: 0.1)
                                : Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasGeminiKey
                                  ? Colors.teal.withValues(alpha: 0.3)
                                  : Colors.amber.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasGeminiKey ? Icons.check_circle : Icons.vpn_key,
                                size: 16,
                                color: hasGeminiKey ? Colors.teal : Colors.amber[800],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasGeminiKey
                                      ? 'Gemini Vision AI Active (Google 1.5 Flash)'
                                      : 'Tap to configure free Gemini API key',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: hasGeminiKey ? Colors.teal : Colors.amber[900],
                                  ),
                                ),
                              ),
                              Text(
                                hasGeminiKey ? 'Change' : 'Set Key',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: hasGeminiKey ? Colors.teal : Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Action Buttons (Camera, Gallery)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('receipt_camera_button'),
                            onPressed: _isProcessing
                                ? null
                                : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('receipt_gallery_button'),
                            onPressed: _isProcessing
                                ? null
                                : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Indian Receipt Samples
                    Text(
                      'Sample Receipts for Quick Testing:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: samples.map((sample) {
                        return ActionChip(
                          avatar: const Icon(Icons.receipt, size: 16),
                          label: Text(sample.title),
                          onPressed: () => _loadSample(sample),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // OCR / Receipt Text Field
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Receipt Text / OCR Output',
                        hintText: 'Paste or type receipt details here...',
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _textController.clear();
                                  _parseCurrentText('');
                                },
                              )
                            : null,
                      ),
                      onChanged: _parseCurrentText,
                    ),
                    const SizedBox(height: 16),

                    // Status / Progress
                    if (_isProcessing)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              if (_statusMessage != null)
                                Text(
                                  _statusMessage!,
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ),

                    if (_statusMessage != null && !_isProcessing)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _statusMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _parsedReceipt?.amountPaise != null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Detected Candidate Amounts Chips (Tap to Select)
                    if (_parsedReceipt != null &&
                        _parsedReceipt!.candidateAmountsPaise.isNotEmpty) ...[
                      Text(
                        'Detected Amounts on Bill (tap to select):',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _parsedReceipt!.candidateAmountsPaise.map((amt) {
                          final isSelected = _parsedReceipt!.amountPaise == amt;
                          return FilterChip(
                            selected: isSelected,
                            avatar: isSelected
                                ? const Icon(Icons.check, size: 16)
                                : const Icon(Icons.currency_rupee, size: 14),
                            label: Text(Money.formatRupees(amt)),
                            selectedColor: theme.colorScheme.primaryContainer,
                            onSelected: (_) {
                              setState(() {
                                _parsedReceipt = _parsedReceipt!.copyWith(amountPaise: amt);
                                _statusMessage = 'Selected Total: ${Money.formatRupees(amt)}';
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Parsed Result Card
                    if (_parsedReceipt != null) ...[
                      Card(
                        elevation: 1,
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'EXTRACTED BILL DETAILS',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${(_parsedReceipt!.confidence * 100).toInt()}% Match',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              _DetailRow(
                                icon: Icons.storefront,
                                label: 'Merchant',
                                value: _parsedReceipt!.merchantName ?? 'Unknown Merchant',
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                icon: Icons.currency_rupee,
                                label: 'Total Amount',
                                value: _parsedReceipt!.amountPaise != null
                                    ? Money.formatRupees(_parsedReceipt!.amountPaise!)
                                    : 'Not detected',
                                isHighlight: true,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                icon: Icons.calendar_today,
                                label: 'Date',
                                value: _parsedReceipt!.date != null
                                    ? '${_parsedReceipt!.date!.day.toString().padLeft(2, '0')}/${_parsedReceipt!.date!.month.toString().padLeft(2, '0')}/${_parsedReceipt!.date!.year}'
                                    : 'Today (Not detected)',
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                icon: Icons.category,
                                label: 'Category',
                                value: _parsedReceipt!.suggestedCategory,
                              ),
                              if (_parsedReceipt!.items.isNotEmpty) ...[
                                const Divider(height: 16),
                                Text(
                                  'Items Detected:',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ..._parsedReceipt!.items.take(4).map(
                                      (it) => Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                                        child: Text(
                                          '• $it',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        key: const Key('apply_scanned_receipt_button'),
                        onPressed: _parsedReceipt!.amountPaise != null
                            ? _applyReceipt
                            : null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Apply to Expense'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
