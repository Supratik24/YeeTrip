import 'dart:io';

import 'package:flutter/material.dart';

/// Full-screen interactive proof viewer for attached expense bill photos.
class ReceiptPreviewDialog extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;

  const ReceiptPreviewDialog({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
  });

  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    required String title,
    String? subtitle,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ReceiptPreviewDialog(
        imagePath: imagePath,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: file.existsSync()
                  ? InteractiveViewer(
                      minScale: 0.7,
                      maxScale: 5.0,
                      child: Center(
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Receipt photo file not found on device.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
