import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/money.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/services/local_image_store.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/traveler_avatar.dart';
import '../../../../data/providers.dart';
import '../../domain/trip_model.dart';
import '../widgets/contact_picker_sheet.dart';
import '../widgets/trip_cover_picker.dart';

class _EditableTraveler {
  final String? id; // null if newly added
  final TextEditingController nameController;
  final TextEditingController vpaController;
  final FocusNode nameFocusNode;
  final FocusNode vpaFocusNode;
  String? avatarPath;
  bool clearAvatar;
  String? phone;

  _EditableTraveler({
    this.id,
    required String name,
    String? upiVpa,
    this.avatarPath,
    this.phone,
  })  : clearAvatar = false,
        nameController = TextEditingController(text: name),
        vpaController = TextEditingController(text: upiVpa ?? ''),
        nameFocusNode = FocusNode(),
        vpaFocusNode = FocusNode();

  void dispose() {
    nameController.dispose();
    vpaController.dispose();
    nameFocusNode.dispose();
    vpaFocusNode.dispose();
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
  final _scrollController = ScrollController();

  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _daysController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _destinationFocusNode = FocusNode();
  final _budgetFocusNode = FocusNode();
  final _daysFocusNode = FocusNode();

  final List<_EditableTraveler> _travelers = [];
  final List<String> _deletedTravelerIds = [];

  String? _initialDestination;
  String? _initialCoverPhotoPath;
  String _initialStatus = 'active';
  String _initialCurrency = 'INR';
  DateTime? _initialStartDate;
  DateTime? _initialEndDate;

  String? _coverPhotoPath;
  String _status = 'active';
  String _currency = 'INR';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _initialized = false;
  bool _isSubmitting = false;
  String? _travelersError;

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _daysController.dispose();
    _nameFocusNode.dispose();
    _destinationFocusNode.dispose();
    _budgetFocusNode.dispose();
    _daysFocusNode.dispose();
    for (final t in _travelers) {
      t.dispose();
    }
    super.dispose();
  }

  void _initFromTrip(TripWithDetails trip) {
    if (_initialized) return;

    _nameController.text = trip.name;
    _initialDestination = trip.destination;
    _destinationController.text = trip.destination ?? '';
    _initialCoverPhotoPath = trip.coverPhotoPath;
    _coverPhotoPath = trip.coverPhotoPath;
    _initialStatus = trip.status;
    _status = trip.status;
    _initialCurrency = trip.currency;
    _currency = TripCurrency.fromCode(trip.currency).code;
    _initialStartDate = trip.startDate;
    _initialEndDate = trip.endDate;
    _startDate = trip.startDate;
    _endDate = trip.endDate;
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
          avatarPath: t.avatarPath,
          phone: t.phone,
        ),
      );
    }
    _initialized = true;
  }

  void _addTraveler({
    bool requestFocus = true,
    String name = '',
    String? upiVpa,
    String? phone,
  }) {
    final traveler = _EditableTraveler(name: name, upiVpa: upiVpa, phone: phone);
    setState(() {
      _travelers.add(traveler);
      _travelersError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (requestFocus) {
        traveler.nameFocusNode.requestFocus();
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
        .map((t) => t.nameController.text.trim())
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

        final alreadyExists = _travelers.any(
          (t) => t.nameController.text.trim().toLowerCase() == name.toLowerCase(),
        );
        if (!alreadyExists) {
          _travelers.add(
            _EditableTraveler(name: name, phone: contact.phoneNumber),
          );
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

    if (_travelersError != null) {
      setState(() => _travelersError = null);
    }
    return true;
  }

  Future<void> _pickTravelerAvatar(int index) async {
    final t = _travelers[index];
    final hasPhoto = t.avatarPath != null &&
        t.avatarPath!.isNotEmpty &&
        File(t.avatarPath!).existsSync();

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photo from gallery'),
              onTap: () => Navigator.of(ctx).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo with camera'),
              onTap: () => Navigator.of(ctx).pop('camera'),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Reset to initials avatar'),
                onTap: () => Navigator.of(ctx).pop('clear'),
              ),
          ],
        ),
      ),
    );

    if (choice == null || !mounted) return;
    if (choice == 'clear') {
      setState(() {
        t.avatarPath = null;
        t.clearAvatar = true;
      });
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked == null) return;
      final saved = await LocalImageStore.persistImage(
        picked.path,
        folder: 'avatars',
      );
      if (mounted) {
        setState(() {
          t.avatarPath = saved;
          t.clearAvatar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photo: $e')),
        );
      }
    }
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
      final destText = _destinationController.text.trim();
      final destChanged = destText != (_initialDestination ?? '');
      final coverChanged = _coverPhotoPath != _initialCoverPhotoPath;
      final statusChanged = _status != _initialStatus;
      final currencyChanged = _currency != _initialCurrency;
      final datesChanged =
          _startDate != _initialStartDate || _endDate != _initialEndDate;

      // 1. Update Trip Details (only include metadata flags if modified)
      if (!destChanged &&
          !coverChanged &&
          !statusChanged &&
          !datesChanged &&
          !currencyChanged) {
        await tripRepo.updateTripDetails(
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          totalBudgetPaise: totalBudgetPaise,
          days: days,
        );
      } else {
        await tripRepo.updateTripDetails(
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          totalBudgetPaise: totalBudgetPaise,
          days: days,
          destination: destChanged && destText.isNotEmpty ? destText : null,
          clearDestination: destChanged && destText.isEmpty,
          coverPhotoPath: coverChanged ? _coverPhotoPath : null,
          clearCoverPhoto: coverChanged && _coverPhotoPath == null,
          status: statusChanged ? _status : null,
          startDate: datesChanged ? _startDate : null,
          endDate: datesChanged ? _endDate : null,
          clearDates: datesChanged && (_startDate == null || _endDate == null),
          currency: currencyChanged ? _currency : null,
        );
      }

      if (datesChanged && _startDate != null) {
        final updated = await tripRepo.getTripById(widget.tripId);
        if (updated != null) {
          await ref
              .read(tripNotificationServiceProvider)
              .scheduleTripStartReminder(updated);
        }
      }

      // 2. Process Deleted Travelers
      for (final deletedId in _deletedTravelerIds) {
        await tripRepo.deleteTraveler(deletedId);
      }

      // 3. Process Existing & New Travelers
      for (final t in _travelers) {
        final name = t.nameController.text.trim();
        final vpa = t.vpaController.text.trim();

        if (t.id != null) {
          if (t.clearAvatar || t.avatarPath != null || t.phone != null) {
            await tripRepo.updateTraveler(
              travelerId: t.id!,
              name: name,
              upiVpa: vpa.isNotEmpty ? vpa : null,
              avatarPath: t.avatarPath,
              clearAvatarPath: t.clearAvatar,
              phone: t.phone,
            );
          } else {
            await tripRepo.updateTraveler(
              travelerId: t.id!,
              name: name,
              upiVpa: vpa.isNotEmpty ? vpa : null,
            );
          }
        } else {
          if (t.avatarPath != null || t.phone != null) {
            await tripRepo.addTraveler(
              tripId: widget.tripId,
              name: name,
              upiVpa: vpa.isNotEmpty ? vpa : null,
              avatarPath: t.avatarPath,
              phone: t.phone,
            );
          } else {
            await tripRepo.addTraveler(
              tripId: widget.tripId,
              name: name,
              upiVpa: vpa.isNotEmpty ? vpa : null,
            );
          }
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
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Trip Name
                    TextFormField(
                      key: const Key('edit_trip_name_field'),
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _destinationFocusNode.requestFocus(),
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
                    const SizedBox(height: 14),

                    // Destination
                    TextFormField(
                      key: const Key('edit_trip_destination_field'),
                      controller: _destinationController,
                      focusNode: _destinationFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _budgetFocusNode.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Destination (optional)',
                        hintText: 'e.g. Goa, Manali, Kerala',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),

                    // Cover Photo, Dates & Active/Completed Status
                    TripCoverAndDatesPicker(
                      coverPhotoPath: _coverPhotoPath,
                      destinationPreview: _destinationController.text,
                      startDate: _startDate,
                      endDate: _endDate,
                      status: _status,
                      onCoverChanged: (path) =>
                          setState(() => _coverPhotoPath = path),
                      onDatesChanged: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                          if (start != null && end != null) {
                            final computed = end.difference(start).inDays + 1;
                            if (computed >= 1) {
                              _daysController.text = computed.toString();
                            }
                          }
                        });
                      },
                      onStatusChanged: (newStatus) =>
                          setState(() => _status = newStatus),
                    ),
                    const SizedBox(height: 16),

                    // Trip currency selector
                    DropdownButtonFormField<String>(
                      key: const Key('edit_trip_currency_dropdown'),
                      initialValue: _currency,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Trip currency',
                        prefixIcon: Icon(Icons.currency_exchange, size: 20),
                      ),
                      items: TripCurrency.all
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.code,
                              child: Text(
                                '${c.flag} ${c.code} (${c.symbol.trim()}) — ${c.name}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _currency = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Total Budget & Duration
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            key: const Key('edit_trip_budget_field'),
                            controller: _budgetController,
                            focusNode: _budgetFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _daysFocusNode.requestFocus(),
                            decoration: InputDecoration(
                              labelText:
                                  'Total budget (${Money.symbolFor(_currency).trim()})',
                              prefixText: '${Money.symbolFor(_currency).trim()} ',
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
                            focusNode: _daysFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              if (_travelers.isNotEmpty) {
                                _travelers.first.nameFocusNode.requestFocus();
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
                                '${_travelers.length} companion${_travelers.length == 1 ? "" : "s"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Contacts import button
                        OutlinedButton.icon(
                          key: const Key('edit_import_contacts_button'),
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
                          key: const Key('add_traveler_btn'),
                          onPressed: () => _addTraveler(requestFocus: true),
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
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

                    // Traveler cards
                    ...List.generate(_travelers.length, (index) {
                      final t = _travelers[index];
                      final isLast = index == _travelers.length - 1;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                key: Key('edit_traveler_avatar_$index'),
                                onTap: () => _pickTravelerAvatar(index),
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    TravelerAvatar(
                                      name: t.nameController.text.trim().isNotEmpty
                                          ? t.nameController.text.trim()
                                          : '${index + 1}',
                                      avatarPath: t.avatarPath,
                                      radius: 18,
                                      fontSize: 11,
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 9,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                      focusNode: t.nameFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) => t.vpaFocusNode.requestFocus(),
                                      decoration: const InputDecoration(
                                        labelText: 'Name',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                      onChanged: (_) {
                                        if (_travelersError != null) {
                                          _validateTravelers();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      key: Key('edit_traveler_vpa_$index'),
                                      controller: t.vpaController,
                                      focusNode: t.vpaFocusNode,
                                      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        if (isLast) {
                                          _addTraveler(requestFocus: true);
                                        } else {
                                          _travelers[index + 1].nameFocusNode.requestFocus();
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'UPI ID (optional)',
                                        hintText: 'e.g. name@bank or 9876543210@upi',
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
