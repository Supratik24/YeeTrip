import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../domain/trip_model.dart';

class _EditableTraveler {
  final String? id; // null if newly added
  final TextEditingController nameController;
  final TextEditingController vpaController;

  _EditableTraveler({
    this.id,
    required String name,
    String? upiVpa,
  })  : nameController = TextEditingController(text: name),
        vpaController = TextEditingController(text: upiVpa ?? '');

  void dispose() {
    nameController.dispose();
    vpaController.dispose();
  }
}

/// Screen to edit an existing trip's details and manage travelers.
class TripEditScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripEditScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends ConsumerState<TripEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _daysController = TextEditingController();

  final List<_EditableTraveler> _travelers = [];
  final List<String> _deletedTravelerIds = [];

  bool _initialized = false;
  bool _isSubmitting = false;
  String? _travelersError;

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _daysController.dispose();
    for (final t in _travelers) {
      t.dispose();
    }
    super.dispose();
  }

  void _initFromTrip(TripWithDetails trip) {
    if (_initialized) return;

    _nameController.text = trip.name;
    _budgetController.text = (trip.totalBudgetPaise % 100 == 0)
        ? (trip.totalBudgetPaise ~/ 100).toString()
        : Money.paiseToDecimalString(trip.totalBudgetPaise);
    _daysController.text = trip.days.toString();

    for (final t in trip.travelers) {
      _travelers.add(
        _EditableTraveler(
          id: t.id,
          name: t.name,
          upiVpa: t.upiVpa,
        ),
      );
    }
    _initialized = true;
  }

  void _addTraveler() {
    setState(() {
      _travelers.add(_EditableTraveler(name: ''));
      _travelersError = null;
    });
  }

  Future<void> _removeTraveler(int index) async {
    if (_travelers.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A trip must have at least one traveler.')),
      );
      return;
    }

    final traveler = _travelers[index];

    // If traveler already exists in database, verify they can be deleted
    if (traveler.id != null) {
      final tripRepo = ref.read(tripRepositoryProvider);
      final canDelete = await tripRepo.canDeleteTraveler(traveler.id!);

      if (!canDelete && mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cannot remove traveler'),
            content: Text(
              '${traveler.nameController.text.trim()} cannot be removed because they have logged expenses or split shares assigned to them.\n\nPlease reassign or delete their expenses before removing them.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove traveler?'),
            content: Text(
              'Remove "${traveler.nameController.text.trim()}" from the trip?',
            ),
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
                child: const Text('Remove'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
        _deletedTravelerIds.add(traveler.id!);
      }
    }

    setState(() {
      traveler.dispose();
      _travelers.removeAt(index);
      _validateTravelers();
    });
  }

  bool _validateTravelers() {
    final names = _travelers
        .map((t) => t.nameController.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      setState(() => _travelersError = 'Add at least one traveler');
      return false;
    }

    if (names.length < _travelers.length) {
      setState(() => _travelersError = 'Traveler names cannot be blank');
      return false;
    }

    final lowerNames = names.map((n) => n.toLowerCase()).toSet();
    if (lowerNames.length < names.length) {
      setState(() => _travelersError = 'Traveler names must be unique');
      return false;
    }

    setState(() => _travelersError = null);
    return true;
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final areTravelersValid = _validateTravelers();

    if (!isFormValid || !areTravelersValid) return;

    setState(() => _isSubmitting = true);

    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      final totalBudgetPaise = Money.decimalStringToPaise(_budgetController.text);
      final days = int.parse(_daysController.text.trim());

      // 1. Update Trip Details
      await tripRepo.updateTripDetails(
        tripId: widget.tripId,
        name: _nameController.text.trim(),
        totalBudgetPaise: totalBudgetPaise,
        days: days,
      );

      // 2. Process Deleted Travelers
      for (final deletedId in _deletedTravelerIds) {
        await tripRepo.deleteTraveler(deletedId);
      }

      // 3. Process Existing & New Travelers
      for (final t in _travelers) {
        final name = t.nameController.text.trim();
        final vpa = t.vpaController.text.trim();

        if (t.id != null) {
          // Update existing traveler
          await tripRepo.updateTraveler(
            travelerId: t.id!,
            name: name,
            upiVpa: vpa.isNotEmpty ? vpa : null,
          );
        } else {
          // Insert newly added traveler
          await tripRepo.addTraveler(
            tripId: widget.tripId,
            name: name,
            upiVpa: vpa.isNotEmpty ? vpa : null,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating trip: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final theme = Theme.of(context);

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit trip')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (trip) {
        if (trip == null) {
          return const Scaffold(body: Center(child: Text('Trip not found')));
        }

        _initFromTrip(trip);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit trip details'),
          ),
          body: SafeArea(
            child: ResponsiveCenter(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Trip Name
                    TextFormField(
                      key: const Key('edit_trip_name_field'),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Trip name',
                        hintText: 'e.g. Goa with friends',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Trip name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Total Budget & Duration
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            key: const Key('edit_trip_budget_field'),
                            controller: _budgetController,
                            decoration: const InputDecoration(
                              labelText: 'Total budget (₹)',
                              prefixText: '₹ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Budget is required';
                              }
                              try {
                                final paise = Money.decimalStringToPaise(val);
                                if (paise <= 0) {
                                  return 'Budget must be > 0';
                                }
                              } catch (_) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            key: const Key('edit_trip_days_field'),
                            controller: _daysController,
                            decoration: const InputDecoration(
                              labelText: 'Days',
                              hintText: 'e.g. 4',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              final d = int.tryParse(val.trim());
                              if (d == null || d < 1) {
                                return 'Min 1 day';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Travelers Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Travelers',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Manage names and optional UPI IDs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          key: const Key('add_traveler_btn'),
                          onPressed: _addTraveler,
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: const Text('Add person'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_travelersError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _travelersError!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    // Traveler cards
                    ...List.generate(_travelers.length, (index) {
                      final t = _travelers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      key: Key('edit_traveler_name_$index'),
                                      controller: t.nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                      onChanged: (_) => _validateTravelers(),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      key: Key('edit_traveler_vpa_$index'),
                                      controller: t.vpaController,
                                      decoration: const InputDecoration(
                                        labelText: 'UPI ID (optional)',
                                        hintText: 'e.g. name@okhdfcbank',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  ],
                                ),
                              ),
                              if (_travelers.length > 1) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  key: Key('remove_traveler_btn_$index'),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.grey.shade600,
                                  onPressed: () => _removeTraveler(index),
                                  tooltip: 'Remove traveler',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Submit Button
                    FilledButton(
                      key: const Key('save_trip_changes_btn'),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
