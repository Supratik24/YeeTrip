import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../auth/presentation/widgets/auth_modal.dart';
import '../widgets/contact_picker_sheet.dart';

/// Helper to manage controller and focus node for a traveler field.
class _TravelerField {
  final TextEditingController controller;
  final FocusNode focusNode;

  _TravelerField({String text = ''})
      : controller = TextEditingController(text: text),
        focusNode = FocusNode();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

/// Screen to create and set up a new trip.
class TripSetupScreen extends ConsumerStatefulWidget {
  const TripSetupScreen({super.key});

  @override
  ConsumerState<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends ConsumerState<TripSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _daysController = TextEditingController(text: '1');

  final _nameFocusNode = FocusNode();
  final _budgetFocusNode = FocusNode();
  final _daysFocusNode = FocusNode();

  final List<_TravelerField> _travelers = [];

  String? _travelersError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    final initialName = (currentUser != null && currentUser.displayName.trim().isNotEmpty)
        ? currentUser.displayName.trim()
        : 'You';
    _travelers.add(_TravelerField(text: initialName));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _budgetController.dispose();
    _daysController.dispose();
    _nameFocusNode.dispose();
    _budgetFocusNode.dispose();
    _daysFocusNode.dispose();
    for (final t in _travelers) {
      t.dispose();
    }
    super.dispose();
  }

  void _addTraveler({bool requestFocus = true, String initialText = ''}) {
    final newField = _TravelerField(text: initialText);
    setState(() {
      _travelers.add(newField);
      _travelersError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (requestFocus) {
        newField.focusNode.requestFocus();
      }
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _importFromContacts() async {
    final existingNames = _travelers
        .map((t) => t.controller.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    final results = await showContactPicker(
      context: context,
      existingNames: existingNames,
    );

    if (results == null || results.isEmpty) return;

    int addedCount = 0;
    setState(() {
      for (final contact in results) {
        final name = contact.name.trim();
        if (name.isEmpty) continue;

        // If the first traveler is still default 'You' and not modified, replace it
        if (_travelers.length == 1 && _travelers[0].controller.text.trim() == 'You') {
          _travelers[0].controller.text = name;
          addedCount++;
          continue;
        }

        // Avoid adding duplicate name
        final alreadyExists = _travelers.any(
          (t) => t.controller.text.trim().toLowerCase() == name.toLowerCase(),
        );
        if (!alreadyExists) {
          _travelers.add(_TravelerField(text: name));
          addedCount++;
        }
      }
      _travelersError = null;
    });

    if (addedCount > 0 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $addedCount traveler${addedCount > 1 ? "s" : ""} from contacts'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeTraveler(int index) {
    if (_travelers.length <= 1) return;
    setState(() {
      final removed = _travelers.removeAt(index);
      removed.dispose();
      _validateTravelers();
    });
  }

  bool _validateTravelers() {
    final names = _travelers
        .map((c) => c.controller.text.trim())
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

    if (_travelersError != null) {
      setState(() => _travelersError = null);
    }
    return true;
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final areTravelersValid = _validateTravelers();

    if (!isFormValid || !areTravelersValid) return;

    // Check mandatory authentication for trip creation
    final auth = ref.read(authServiceProvider);
    if (auth.currentState.isGuest) {
      final user = await showModalBottomSheet<UserProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AuthModal(
          reason: 'Sign in or create an account to save this trip',
        ),
      );
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in is required to create a trip'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      // If traveler 0 was still default 'You', update it to the user's name
      if (_travelers.isNotEmpty && _travelers[0].controller.text == 'You') {
        _travelers[0].controller.text = user.displayName;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final totalBudgetPaise =
          Money.decimalStringToPaise(_budgetController.text);
      final days = int.parse(_daysController.text.trim());
      final travelerNames =
          _travelers.map((c) => c.controller.text.trim()).toList();

      final tripRepo = ref.read(tripRepositoryProvider);
      final tripId = await tripRepo.createTrip(
        name: name,
        totalBudgetPaise: totalBudgetPaise,
        days: days,
        travelerNames: travelerNames,
      );

      // Auto-link traveler profile and default UPI to the new trip
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final migration = ref.read(profileMigrationServiceProvider);
        await migration.linkProfileToLocalTrips(currentUser);
      }

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
    final authState = ref.watch(authStateProvider).value ?? ref.watch(authServiceProvider).currentState;
    final isGuest = authState.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan new trip'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                if (isGuest) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sign-in required: You will be asked to sign in or create an account to save this trip.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AuthModal(
                              reason: 'Sign in or create an account to plan a trip',
                            ),
                          ),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ],
                // Trip name
                TextFormField(
                  key: const Key('trip_name_field'),
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _budgetFocusNode.requestFocus(),
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
                        focusNode: _budgetFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _daysFocusNode.requestFocus(),
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
                        focusNode: _daysFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          if (_travelers.isNotEmpty) {
                            _travelers.first.focusNode.requestFocus();
                          }
                        },
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

                // Travelers section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Travelers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_travelers.length} companion${_travelers.length == 1 ? "" : "s"}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contact import button
                    OutlinedButton.icon(
                      key: const Key('import_contacts_button'),
                      onPressed: _importFromContacts,
                      icon: const Icon(Icons.perm_contact_calendar_outlined, size: 16),
                      label: const Text('Contacts'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add person button
                    TextButton.icon(
                      key: const Key('add_traveler_button'),
                      onPressed: () => _addTraveler(requestFocus: true),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add person'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
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
                ...List.generate(_travelers.length, (index) {
                  final traveler = _travelers[index];
                  final isLast = index == _travelers.length - 1;

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
                            controller: traveler.controller,
                            focusNode: traveler.focusNode,
                            textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                            onFieldSubmitted: (_) {
                              if (isLast) {
                                _addTraveler(requestFocus: true);
                              } else {
                                _travelers[index + 1].focusNode.requestFocus();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Traveler ${index + 1} name',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) {
                              if (_travelersError != null) {
                                _validateTravelers();
                              }
                            },
                          ),
                        ),
                        if (_travelers.length > 1) ...[
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
      ),
    );
  }
}
