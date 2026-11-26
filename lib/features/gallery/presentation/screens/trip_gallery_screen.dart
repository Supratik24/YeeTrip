import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/local_image_store.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/trip_photo_model.dart';

enum _GalleryFilter {
  all('All'),
  memories('Memories'),
  receipts('Receipts');

  final String label;
  const _GalleryFilter(this.label);
}

/// Shared trip photo gallery aggregating traveler memories and expense receipt photos.
class TripGalleryScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripGalleryScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripGalleryScreen> createState() => _TripGalleryScreenState();
}

class _TripGalleryScreenState extends ConsumerState<TripGalleryScreen> {
  final _picker = ImagePicker();
  _GalleryFilter _filter = _GalleryFilter.all;
  int? _selectedDayFilter;
  bool _isAdding = false;

  Future<void> _addFromCamera(TripWithDetails trip) async {
    setState(() => _isAdding = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
      if (file == null || !mounted) return;
      final saved = await LocalImageStore.persistImage(
        file.path,
        folder: 'gallery',
      );
      if (!mounted) return;
      await _promptMetadataAndSave(trip, [saved]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _addFromGallery(TripWithDetails trip) async {
    setState(() => _isAdding = true);
    try {
      final files = await _picker.pickMultiImage(
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
      if (files.isEmpty || !mounted) return;
      final savedPaths = <String>[];
      for (final f in files) {
        savedPaths.add(
          await LocalImageStore.persistImage(f.path, folder: 'gallery'),
        );
      }
      if (!mounted) return;
      await _promptMetadataAndSave(trip, savedPaths);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _promptMetadataAndSave(
    TripWithDetails trip,
    List<String> paths,
  ) async {
    final captionController = TextEditingController();
    var selectedDay = 1;
    Traveler? selectedTraveler =
        trip.travelers.isNotEmpty ? trip.travelers.first : null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            paths.length == 1
                ? 'Add photo to trip gallery'
                : 'Add ${paths.length} photos to gallery',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trip.travelers.isNotEmpty)
                  DropdownButtonFormField<String>(
                  initialValue: selectedTraveler?.id,
                  decoration: const InputDecoration(
                    labelText: 'Added by',
                    isDense: true,
                  ),
                  items: trip.travelers
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    setDialogState(() {
                      selectedTraveler = trip.travelers.firstWhere(
                        (t) => t.id == id,
                        orElse: () => trip.travelers.first,
                      );
                    });
                  },
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Trip day',
                  isDense: true,
                ),
                items: List.generate(
                  trip.days < 1 ? 1 : trip.days,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Day ${i + 1}'),
                  ),
                ),
                onChanged: (d) {
                  if (d != null) setDialogState(() => selectedDay = d);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('gallery_photo_caption_field'),
                controller: captionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Caption (optional)',
                  hintText: 'e.g. Sunset at Chapora Fort',
                  isDense: true,
                ),
              ),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirm_add_gallery_photo_btn'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    final caption = captionController.text.trim();
    captionController.dispose();

    if (confirmed != true) return;
    final repo = ref.read(tripPhotoRepositoryProvider);
    for (final path in paths) {
      await repo.addPhoto(
        tripId: trip.id,
        imagePath: path,
        caption: caption.isNotEmpty ? caption : null,
        dayNumber: selectedDay,
        uploadedByTravelerId: selectedTraveler?.id,
        uploadedByName: selectedTraveler?.name ?? 'You',
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paths.length == 1
                ? 'Added photo to Day $selectedDay!'
                : 'Added ${paths.length} photos to Day $selectedDay!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<TripPhotoModel> _mergeGalleryItems(
    TripWithDetails trip,
    List<TripPhotoModel> memories,
    List<ExpenseWithSplits> expenses,
  ) {
    final anchor = trip.startDate ?? trip.createdAt;
    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);
    final travelerNames = {
      for (final t in trip.travelers) t.id: t.name,
    };

    final receiptPhotos = <TripPhotoModel>[
      for (final exp in expenses)
        if (exp.receiptImagePath != null &&
            exp.receiptImagePath!.trim().isNotEmpty)
          TripPhotoModel(
            id: 'receipt_${exp.id}',
            tripId: trip.id,
            imagePath: exp.receiptImagePath!,
            caption: '${exp.description} (${exp.category} Bill)',
            dayNumber: (DateTime(
                      exp.createdAt.year,
                      exp.createdAt.month,
                      exp.createdAt.day,
                    ).difference(anchorDay).inDays +
                    1)
                .clamp(1, trip.days < 1 ? 1 : trip.days),
            uploadedByTravelerId: exp.paidBy,
            uploadedByName: travelerNames[exp.paidBy] ?? 'Receipt',
            createdAt: exp.createdAt,
            isReceipt: true,
            sourceExpenseId: exp.id,
          ),
    ];

    final combined = switch (_filter) {
      _GalleryFilter.all => [...memories, ...receiptPhotos],
      _GalleryFilter.memories => memories,
      _GalleryFilter.receipts => receiptPhotos,
    };

    final dayFiltered = _selectedDayFilter == null
        ? combined
        : combined
            .where((p) => p.dayNumber == _selectedDayFilter)
            .toList();

    dayFiltered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return dayFiltered;
  }

  Future<void> _openViewer(
    BuildContext context,
    TripWithDetails trip,
    TripPhotoModel photo,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _PhotoViewerDialog(
        trip: trip,
        photo: photo,
        onSetCover: () async {
          await ref.read(tripRepositoryProvider).updateTripDetails(
                tripId: trip.id,
                name: trip.name,
                totalBudgetPaise: trip.totalBudgetPaise,
                days: trip.days,
                coverPhotoPath: photo.imagePath,
              );
          if (ctx.mounted) Navigator.of(ctx).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Updated trip cover photo!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onEditCaption: photo.isReceipt
            ? null
            : () async {
                Navigator.of(ctx).pop();
                await _editPhotoCaption(trip, photo);
              },
        onDelete: photo.isReceipt
            ? null
            : () async {
                Navigator.of(ctx).pop();
                await ref.read(tripPhotoRepositoryProvider).deletePhoto(photo.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed photo from gallery'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
      ),
    );
  }

  Future<void> _editPhotoCaption(
    TripWithDetails trip,
    TripPhotoModel photo,
  ) async {
    final controller = TextEditingController(text: photo.caption ?? '');
    var day = photo.dayNumber;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit photo details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: day.clamp(1, trip.days < 1 ? 1 : trip.days),
                decoration: const InputDecoration(
                  labelText: 'Day',
                  isDense: true,
                ),
                items: List.generate(
                  trip.days < 1 ? 1 : trip.days,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Day ${i + 1}'),
                  ),
                ),
                onChanged: (d) {
                  if (d != null) setDialogState(() => day = d);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    final updatedCaption = controller.text.trim();
    controller.dispose();
    if (saved == true) {
      await ref.read(tripPhotoRepositoryProvider).updateCaption(
            photoId: photo.id,
            caption: updatedCaption,
            dayNumber: day,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final photosAsync = ref.watch(tripPhotosProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Photo Gallery')),
        body: Center(child: Text('Error loading trip: $err')),
      ),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Photo Gallery')),
            body: const Center(child: Text('Trip not found')),
          );
        }

        final memories = photosAsync.value ?? const <TripPhotoModel>[];
        final expenses = expensesAsync.value ?? const <ExpenseWithSplits>[];
        final displayed = _mergeGalleryItems(trip, memories, expenses);

        return Scaffold(
          appBar: AppBar(
            title: Text('${trip.name} • Photos'),
            actions: [
              IconButton(
                key: const Key('gallery_appbar_camera_btn'),
                tooltip: 'Take photo',
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: _isAdding ? null : () => _addFromCamera(trip),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('gallery_add_photo_btn'),
            onPressed: _isAdding ? null : () => _addFromGallery(trip),
            icon: _isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_isAdding ? 'Adding...' : 'Add photos'),
          ),
          body: ResponsiveCenter(
            child: Column(
              children: [
                // Filter bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ..._GalleryFilter.values.map((f) {
                                final selected = _filter == f;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    key: Key('gallery_filter_${f.name}'),
                                    label: Text(f.label),
                                    selected: selected,
                                    onSelected: (_) =>
                                        setState(() => _filter = f),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                );
                              }),
                              const SizedBox(width: 4),
                              PopupMenuButton<int?>(
                                key: const Key('gallery_day_filter_btn'),
                                tooltip: 'Filter by day',
                                onSelected: (d) =>
                                    setState(() => _selectedDayFilter = d),
                                itemBuilder: (_) => [
                                  const PopupMenuItem<int?>(
                                    value: null,
                                    child: Text('All days'),
                                  ),
                                  ...List.generate(
                                    trip.days < 1 ? 1 : trip.days,
                                    (i) => PopupMenuItem<int?>(
                                      value: i + 1,
                                      child: Text('Day ${i + 1}'),
                                    ),
                                  ),
                                ],
                                child: Chip(
                                  avatar: const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                  ),
                                  label: Text(
                                    _selectedDayFilter == null
                                        ? 'All days'
                                        : 'Day $_selectedDayFilter',
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Grid or Empty State
                Expanded(
                  child: displayed.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64,
                                  color: colorScheme.primary.withValues(alpha: 0.45),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No trip photos yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Save trip memories or browse attached bill photos by day and traveler.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: _isAdding
                                          ? null
                                          : () => _addFromGallery(trip),
                                      icon: const Icon(
                                        Icons.add_photo_alternate_outlined,
                                      ),
                                      label: const Text('Choose photos'),
                                    ),
                                    OutlinedButton.icon(
                                      key: const Key('gallery_camera_btn'),
                                      onPressed: _isAdding
                                          ? null
                                          : () => _addFromCamera(trip),
                                      icon: const Icon(Icons.camera_alt_outlined),
                                      label: const Text('Camera'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: displayed.length,
                          itemBuilder: (context, index) {
                            final photo = displayed[index];
                            return _GalleryPhotoTile(
                              photo: photo,
                              onTap: () => _openViewer(context, trip, photo),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GalleryPhotoTile extends StatelessWidget {
  final TripPhotoModel photo;
  final VoidCallback onTap;

  const _GalleryPhotoTile({
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final file = File(photo.imagePath);
    final exists = file.existsSync();

    return Card(
      key: Key('gallery_tile_${photo.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (exists)
              Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PlaceholderArt(photo: photo),
              )
            else
              _PlaceholderArt(photo: photo),

            // Bottom gradient + caption + uploader
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (photo.caption != null && photo.caption!.isNotEmpty)
                      Text(
                        photo.caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            photo.uploadedByName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Top badges (Day + optional Receipt pill)
            Positioned(
              top: 6,
              left: 6,
              right: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Day ${photo.dayNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (photo.isReceipt)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Bill',
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

class _PlaceholderArt extends StatelessWidget {
  final TripPhotoModel photo;

  const _PlaceholderArt({required this.photo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          photo.isReceipt ? Icons.receipt_long : Icons.photo_outlined,
          size: 40,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PhotoViewerDialog extends StatelessWidget {
  final TripWithDetails trip;
  final TripPhotoModel photo;
  final VoidCallback onSetCover;
  final VoidCallback? onEditCaption;
  final VoidCallback? onDelete;

  const _PhotoViewerDialog({
    required this.trip,
    required this.photo,
    required this.onSetCover,
    this.onEditCaption,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(photo.imagePath);
    final exists = file.existsSync();

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Day ${photo.dayNumber} • ${photo.uploadedByName}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              actions: [
                if (exists)
                  IconButton(
                    tooltip: 'Share photo',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(photo.imagePath)],
                        text: photo.caption ?? '${trip.name} memory',
                      ),
                    ),
                  ),
                if (onEditCaption != null)
                  IconButton(
                    tooltip: 'Edit caption',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEditCaption,
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Delete photo',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  child: exists
                      ? Image.file(
                          file,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white54,
                          ),
                        )
                      : const Icon(
                          Icons.photo_outlined,
                          size: 72,
                          color: Colors.white54,
                        ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withValues(alpha: 0.72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photo.caption != null && photo.caption!.isNotEmpty) ...[
                    Text(
                      photo.caption!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMM yyyy, h:mm a').format(photo.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (!photo.isReceipt && exists)
                        TextButton.icon(
                          onPressed: onSetCover,
                          icon: const Icon(
                            Icons.wallpaper,
                            size: 16,
                            color: Colors.tealAccent,
                          ),
                          label: const Text(
                            'Set as Cover',
                            style: TextStyle(color: Colors.tealAccent),
                          ),
                        ),
                    ],
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
