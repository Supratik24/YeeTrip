import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money.dart';
import '../../../../data/providers.dart';

/// Screen to create and set up a new trip.
class TripSetupScreen extends ConsumerStatefulWidget {
  const TripSetupScreen({super.key});

  @override
  ConsumerState<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends ConsumerState<TripSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _daysController = TextEditingController(text: '1');

  final List<TextEditingController> _travelerControllers = [
    TextEditingController(text: 'You'),
  ];

  String? _travelersError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _daysController.dispose();
    for (final c in _travelerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTraveler() {
    setState(() {
      _travelerControllers.add(TextEditingController());
      _travelersError = null;
    });
  }

  void _removeTraveler(int index) {
    if (_travelerControllers.length <= 1) return;
    setState(() {
      _travelerControllers[index].dispose();
      _travelerControllers.removeAt(index);
      _validateTravelers();
    });
  }

  bool _validateTravelers() {
    final names = _travelerControllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      setState(() => _travelersError = 'Add at least one traveler');
      return false;
    }

    if (names.length < _travelerControllers.length) {
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
      final name = _nameController.text.trim();
      final totalBudgetPaise =
          Money.decimalStringToPaise(_budgetController.text);
      final days = int.parse(_daysController.text.trim());
      final travelerNames =
          _travelerControllers.map((c) => c.text.trim()).toList();

      final tripRepo = ref.read(tripRepositoryProvider);
      final tripId = await tripRepo.createTrip(
        name: name,
        totalBudgetPaise: totalBudgetPaise,
        days: days,
        travelerNames: travelerNames,
      );

      if (mounted) {
        context.go('/trips/$tripId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating trip: $e')),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan new trip'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Trip name
              TextFormField(
                key: const Key('trip_name_field'),
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

              // Total budget & Days in a responsive row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: const Key('total_budget_field'),
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Total budget (₹)',
                        hintText: 'e.g. 50,000',
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
                            return 'Budget must be greater than zero';
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
                      key: const Key('days_field'),
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

              // Travelers section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Travelers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addTraveler,
                    icon: const Icon(Icons.add, size: 18),
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

              // Dynamic list of travelers
              ...List.generate(_travelerControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          key: Key('traveler_field_$index'),
                          controller: _travelerControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Traveler ${index + 1} name',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => _validateTravelers(),
                        ),
                      ),
                      if (_travelerControllers.length > 1) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.grey.shade600,
                          onPressed: () => _removeTraveler(index),
                          tooltip: 'Remove',
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Create trip submit button
              FilledButton(
                key: const Key('create_trip_button'),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
