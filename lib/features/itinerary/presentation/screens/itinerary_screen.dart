import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/itinerary_model.dart';

/// Day-by-Day Itinerary Planner screen for a trip.
class ItineraryScreen extends ConsumerStatefulWidget {
  final String tripId;

  const ItineraryScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  int _selectedDay = 0; // 0 = All days, 1..N = specific day

  Color _categoryColor(String key) {
    switch (key.toLowerCase()) {
      case 'stay':
        return Colors.blue.shade600;
      case 'food':
        return Colors.orange.shade600;
      case 'transport':
        return Colors.green.shade600;
      case 'activities':
        return Colors.purple.shade600;
      case 'shopping':
        return Colors.pink.shade500;
      case 'buffer':
      default:
        return Colors.teal.shade600;
    }
  }

  IconData _categoryIcon(String key) {
    switch (key.toLowerCase()) {
      case 'stay':
        return Icons.hotel_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'activities':
        return Icons.explore_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'buffer':
      default:
        return Icons.event_note_outlined;
    }
  }

  String _dayHeaderLabel(TripWithDetails trip, int dayNumber) {
    if (trip.startDate != null) {
      final date = trip.startDate!.add(Duration(days: dayNumber - 1));
      return 'Day $dayNumber • ${DateFormat('EEE, dd MMM').format(date)}';
    }
    return 'Day $dayNumber';
  }

  Future<void> _openMapsLocation(String location) async {
    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {'api': '1', 'query': location.trim()},
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Maps for "$location"')),
        );
      }
    }
  }

  void _openAddEditSheet(
    TripWithDetails trip, {
    ItineraryItemModel? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddEditItinerarySheet(
        trip: trip,
        initialDay: existing?.dayNumber ?? (_selectedDay > 0 ? _selectedDay : 1),
        existing: existing,
      ),
    );
  }

  Future<void> _deleteItem(ItineraryItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove activity?'),
        content: Text('Delete "${item.title}" from Day ${item.dayNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(itineraryRepositoryProvider).deleteItem(item.id);
    }
  }

  void _convertToExpense(TripWithDetails trip, ItineraryItemModel item) {
    final params = <String, String>{
      'desc': item.title,
      'cat': item.category,
      if (item.estimatedCostPaise > 0)
        'amt': Money.paiseToDecimalString(item.estimatedCostPaise),
      if (item.notes != null && item.notes!.isNotEmpty) 'notes': item.notes!,
    };
    final uri = Uri(
      path: '/trips/${trip.id}/expenses/new',
      queryParameters: params,
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final itineraryAsync = ref.watch(tripItineraryProvider(widget.tripId));
    final theme = Theme.of(context);

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Itinerary')),
        body: Center(child: Text('Error loading trip: $err')),
      ),
      data: (trip) {
        if (trip == null) {
          return const Scaffold(body: Center(child: Text('Trip not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${trip.name} • Itinerary'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('add_itinerary_item_fab'),
            onPressed: () => _openAddEditSheet(trip),
            icon: const Icon(Icons.add),
            label: const Text('Add activity'),
          ),
          body: ResponsiveCenter(
            child: itineraryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (items) {
                final maxItemDay = items.fold<int>(
                  trip.days,
                  (max, i) => i.dayNumber > max ? i.dayNumber : max,
                );
                final totalCompleted = items.where((i) => i.isCompleted).length;
                final totalPlannedCost = items.fold<int>(
                  0,
                  (sum, i) => sum + i.estimatedCostPaise,
                );

                final filtered = _selectedDay == 0
                    ? items
                    : items
                        .where((i) => i.dayNumber == _selectedDay)
                        .toList();

                // Group by dayNumber preserving ascending day order
                final grouped = <int, List<ItineraryItemModel>>{};
                for (final item in filtered) {
                  grouped.putIfAbsent(item.dayNumber, () => []).add(item);
                }
                final dayKeys = grouped.keys.toList()..sort();

                return Column(
                  children: [
                    // Progress & Cost Summary Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      items.isEmpty
                                          ? '${trip.days}-Day Schedule'
                                          : '$totalCompleted of ${items.length} completed',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: items.isEmpty
                                            ? 0
                                            : totalCompleted / items.length,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Est. plan cost',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    Money.formatAmount(
                                      totalPlannedCost,
                                      currencyCode: trip.currency,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Day filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ChoiceChip(
                            key: const Key('itinerary_day_all'),
                            label: const Text('All days'),
                            selected: _selectedDay == 0,
                            onSelected: (_) =>
                                setState(() => _selectedDay = 0),
                          ),
                          const SizedBox(width: 8),
                          for (int d = 1; d <= maxItemDay; d++) ...[
                            ChoiceChip(
                              key: Key('itinerary_day_$d'),
                              label: Text('Day $d'),
                              selected: _selectedDay == d,
                              onSelected: (_) =>
                                  setState(() => _selectedDay = d),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Timeline / Empty State
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _selectedDay == 0
                                          ? 'No activities planned yet'
                                          : 'Nothing planned for Day $_selectedDay',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap "+ Add activity" to map out stays, transport, dining, and spots per day.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 92),
                              itemCount: dayKeys.length,
                              itemBuilder: (context, idx) {
                                final day = dayKeys[idx];
                                final dayItems = grouped[day]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 6,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _dayHeaderLabel(trip, day),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    ...dayItems.map((item) {
                                      final catColor =
                                          _categoryColor(item.category);
                                      return Card(
                                        key: Key('itinerary_item_${item.id}'),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Checkbox(
                                                    value: item.isCompleted,
                                                    onChanged: (val) => ref
                                                        .read(
                                                          itineraryRepositoryProvider,
                                                        )
                                                        .toggleCompleted(
                                                          item.id,
                                                          val ?? false,
                                                        ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 7,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: catColor
                                                                    .withValues(
                                                                  alpha: 0.14,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  6,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    _categoryIcon(
                                                                      item.category,
                                                                    ),
                                                                    size: 12,
                                                                    color:
                                                                        catColor,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    item.displayTime,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          catColor,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            if (item
                                                                    .estimatedCostPaise >
                                                                0)
                                                              Text(
                                                                Money.formatAmount(
                                                                  item.estimatedCostPaise,
                                                                  currencyCode:
                                                                      trip.currency,
                                                                ),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onSurfaceVariant,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          item.title,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            decoration: item
                                                                    .isCompleted
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : null,
                                                            color: item
                                                                    .isCompleted
                                                                ? Colors.grey
                                                                : null,
                                                          ),
                                                        ),
                                                        if (item.location !=
                                                                null &&
                                                            item.location!
                                                                .isNotEmpty) ...[
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          InkWell(
                                                            onTap: () =>
                                                                _openMapsLocation(
                                                              item.location!,
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on_outlined,
                                                                  size: 14,
                                                                  color: theme
                                                                      .colorScheme
                                                                      .primary,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Flexible(
                                                                  child: Text(
                                                                    item.location!,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: theme
                                                                          .colorScheme
                                                                          .primary,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                        if (item.notes !=
                                                                null &&
                                                            item.notes!
                                                                .isNotEmpty) ...[
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            item.notes!,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuButton<String>(
                                                    onSelected: (action) {
                                                      if (action == 'edit') {
                                                        _openAddEditSheet(
                                                          trip,
                                                          existing: item,
                                                        );
                                                      } else if (action ==
                                                          'expense') {
                                                        _convertToExpense(
                                                          trip,
                                                          item,
                                                        );
                                                      } else if (action ==
                                                          'delete') {
                                                        _deleteItem(item);
                                                      }
                                                    },
                                                    itemBuilder: (_) => const [
                                                      PopupMenuItem(
                                                        value: 'expense',
                                                        child: ListTile(
                                                          leading: Icon(
                                                            Icons.receipt_long,
                                                          ),
                                                          title: Text(
                                                            'Log as expense',
                                                          ),
                                                          dense: true,
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: ListTile(
                                                          leading: Icon(
                                                            Icons.edit_outlined,
                                                          ),
                                                          title: Text('Edit'),
                                                          dense: true,
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: ListTile(
                                                          leading: Icon(
                                                            Icons.delete_outline,
                                                          ),
                                                          title: Text('Delete'),
                                                          dense: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AddEditItinerarySheet extends ConsumerStatefulWidget {
  final TripWithDetails trip;
  final int initialDay;
  final ItineraryItemModel? existing;

  const _AddEditItinerarySheet({
    required this.trip,
    required this.initialDay,
    this.existing,
  });

  @override
  ConsumerState<_AddEditItinerarySheet> createState() =>
      _AddEditItinerarySheetState();
}

class _AddEditItinerarySheetState
    extends ConsumerState<_AddEditItinerarySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  late int _dayNumber;
  late String _category;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _dayNumber = e?.dayNumber ?? widget.initialDay;
    _category = e?.category ?? TripCategory.activities.key;
    _titleController = TextEditingController(text: e?.title ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _costController = TextEditingController(
      text: (e != null && e.estimatedCostPaise > 0)
          ? Money.paiseToDecimalString(e.estimatedCostPaise)
          : '',
    );
    _notesController = TextEditingController(text: e?.notes ?? '');
    if (e?.startTimeMinutes != null) {
      _selectedTime = TimeOfDay(
        hour: e!.startTimeMinutes! ~/ 60,
        minute: e.startTimeMinutes! % 60,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 30),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final costText = _costController.text.trim();
      final costPaise =
          costText.isEmpty ? 0 : Money.decimalStringToPaise(costText);
      final startMinutes = _selectedTime != null
          ? (_selectedTime!.hour * 60 + _selectedTime!.minute)
          : null;
      final repo = ref.read(itineraryRepositoryProvider);

      if (widget.existing == null) {
        await repo.addItem(
          tripId: widget.trip.id,
          dayNumber: _dayNumber,
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          startTimeMinutes: startMinutes,
          category: _category,
          estimatedCostPaise: costPaise,
          notes: _notesController.text.trim(),
        );
      } else {
        await repo.updateItem(
          itemId: widget.existing!.id,
          dayNumber: _dayNumber,
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          startTimeMinutes: startMinutes,
          category: _category,
          estimatedCostPaise: costPaise,
          notes: _notesController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save activity: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dayOptionsCount = widget.trip.days > _dayNumber
        ? widget.trip.days
        : _dayNumber;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'Add activity' : 'Edit activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('itinerary_title_field'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Activity / Reservation',
                  hintText: 'e.g. Scuba Diving at Grande Island',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Activity title is required'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      key: const Key('itinerary_day_dropdown'),
                      initialValue: _dayNumber,
                      decoration: const InputDecoration(labelText: 'Day'),
                      items: [
                        for (int d = 1; d <= dayOptionsCount; d++)
                          DropdownMenuItem(value: d, child: Text('Day $d')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _dayNumber = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time slot',
                          suffixIcon: _selectedTime != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () =>
                                      setState(() => _selectedTime = null),
                                )
                              : const Icon(Icons.schedule, size: 18),
                        ),
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Anytime',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('itinerary_location_field'),
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Place / Location (optional)',
                  hintText: 'e.g. Calangute Beach, North Goa',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: TripCategory.all
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.key,
                              child: Text(c.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('itinerary_cost_field'),
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Est. cost',
                        prefixText:
                            '${Money.symbolFor(widget.trip.currency).trim()} ',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return null;
                        try {
                          Money.decimalStringToPaise(val);
                          return null;
                        } catch (_) {
                          return 'Invalid amount';
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('itinerary_notes_field'),
                controller: _notesController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes / booking ref (optional)',
                  hintText: 'Confirmation code, what to carry, etc.',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                key: const Key('save_itinerary_item_btn'),
                onPressed: _isSaving ? null : _save,
                child: Text(
                  widget.existing == null ? 'Save to itinerary' : 'Update item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
