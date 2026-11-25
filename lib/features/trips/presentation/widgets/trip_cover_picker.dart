import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/local_image_store.dart';

/// Shared widget for choosing a trip cover photo and optional travel date range
/// in [TripSetupScreen] and [TripEditScreen].
class TripCoverAndDatesPicker extends StatelessWidget {
  final String? coverPhotoPath;
  final String? destinationPreview;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final ValueChanged<String?> onCoverChanged;
  final void Function(DateTime? start, DateTime? end) onDatesChanged;
  final ValueChanged<String>? onStatusChanged;

  const TripCoverAndDatesPicker({
    super.key,
    required this.coverPhotoPath,
    this.destinationPreview,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    required this.onCoverChanged,
    required this.onDatesChanged,
    this.onStatusChanged,
  });

  Future<void> _pickCoverImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (file == null) return;
      final savedPath = await LocalImageStore.persistImage(
        file.path,
        folder: 'covers',
      );
      onCoverChanged(savedPath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick cover image: $e')),
        );
      }
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = (startDate != null && endDate != null)
        ? DateTimeRange(start: startDate!, end: endDate!)
        : DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 3)),
          );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: initialRange,
      helpText: 'Select trip start & end dates',
    );
    if (picked != null) {
      onDatesChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = coverPhotoPath != null &&
        coverPhotoPath!.isNotEmpty &&
        File(coverPhotoPath!).existsSync();

    final dateLabel = (startDate != null && endDate != null)
        ? '${DateFormat('dd MMM').format(startDate!)} – ${DateFormat('dd MMM yyyy').format(endDate!)}'
        : 'Select start & end dates (optional)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Preview / Picker Banner
        Container(
          key: const Key('trip_cover_picker_card'),
          height: 126,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
            ),
            gradient: hasFile
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.14),
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
                    ],
                  ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasFile)
                Image.file(
                  File(coverPhotoPath!),
                  fit: BoxFit.cover,
                )
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.landscape_outlined,
                        size: 32,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add trip cover photo (optional)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasFile)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasFile) ...[
                      FilledButton.tonalIcon(
                        key: const Key('remove_cover_photo_btn'),
                        onPressed: () => onCoverChanged(null),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Remove'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    FilledButton.tonalIcon(
                      key: const Key('pick_cover_gallery_btn'),
                      onPressed: () =>
                          _pickCoverImage(context, ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: Text(hasFile ? 'Change' : 'Gallery'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      key: const Key('pick_cover_camera_btn'),
                      onPressed: () =>
                          _pickCoverImage(context, ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      tooltip: 'Take cover photo',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              if (destinationPreview != null &&
                  destinationPreview!.trim().isNotEmpty)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasFile
                          ? Colors.black.withValues(alpha: 0.55)
                          : theme.colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 13,
                          color: hasFile
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destinationPreview!.trim(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasFile
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Date Range Picker Row
        InkWell(
          key: const Key('trip_date_range_btn'),
          onTap: () => _pickDateRange(context),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Trip dates',
              prefixIcon: const Icon(Icons.date_range_outlined, size: 20),
              suffixIcon: (startDate != null && endDate != null)
                  ? IconButton(
                      key: const Key('clear_trip_dates_btn'),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => onDatesChanged(null, null),
                      tooltip: 'Clear dates',
                    )
                  : null,
            ),
            child: Text(
              dateLabel,
              style: TextStyle(
                color: (startDate != null && endDate != null)
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),

        if (onStatusChanged != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              key: const Key('trip_status_segmented'),
              segments: const [
                ButtonSegment(
                  value: 'active',
                  icon: Icon(Icons.flight_takeoff, size: 16),
                  label: Text('Active'),
                ),
                ButtonSegment(
                  value: 'completed',
                  icon: Icon(Icons.check_circle_outline, size: 16),
                  label: Text('Completed'),
                ),
              ],
              selected: {status == 'completed' ? 'completed' : 'active'},
              onSelectionChanged: (set) => onStatusChanged!(set.first),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact formatted trip date span badge string (e.g. `12 Dec – 16 Dec`).
String? formatTripDateSpan(DateTime? startDate, DateTime? endDate) {
  if (startDate == null || endDate == null) return null;
  final sameMonth =
      startDate.year == endDate.year && startDate.month == endDate.month;
  if (sameMonth) {
    return '${DateFormat('d').format(startDate)}–${DateFormat('d MMM').format(endDate)}';
  }
  return '${DateFormat('d MMM').format(startDate)} – ${DateFormat('d MMM').format(endDate)}';
}
