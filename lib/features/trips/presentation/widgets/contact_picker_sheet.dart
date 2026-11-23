import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// Represents a contact selected from device contacts.
class ContactPickerResult {
  final String name;
  final String? phoneNumber;

  const ContactPickerResult({
    required this.name,
    this.phoneNumber,
  });
}

/// In-app notification / disclosure dialog shown before requesting OS contact permission.
Future<bool> showContactPermissionNotification(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.perm_contact_calendar_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Add from Contacts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YeeTrip needs access to your contacts so you can quickly add travel companions to your trip without manually typing each name.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.teal.shade900.withValues(alpha: 0.25)
                  : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.teal.shade700.withValues(alpha: 0.4)
                    : Colors.teal.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: isDark ? Colors.teal.shade300 : Colors.teal.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% Offline & Private: Your contacts stay strictly on your phone. YeeTrip will never upload or share your contacts with anyone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.teal.shade200 : Colors.teal.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Not Now'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Allow & Continue'),
        ),
      ],
    ),
  );

  return result ?? false;
}

/// Launches the contact picker flow with permission notification, contact fetching,
/// and searchable multi-selection.
Future<List<ContactPickerResult>?> showContactPicker({
  required BuildContext context,
  List<String> existingNames = const [],
}) async {
  // If running on desktop / web or platforms without mobile contacts support
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact import is available on mobile devices. Please enter names manually.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return null;
  }

  try {
    // 1. Check if permission is already granted
    final hasPermission =
        await FlutterContacts.permissions.has(PermissionType.read);

    if (!hasPermission) {
      if (!context.mounted) return null;
      // Show mandatory disclosure notification dialog
      final proceed = await showContactPermissionNotification(context);
      if (!proceed) return null;

      // Request OS permission
      final status =
          await FlutterContacts.permissions.request(PermissionType.read);
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.limited) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Contact permission denied. You can enable it in Settings or type names manually.',
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => FlutterContacts.permissions.openSettings(),
              ),
            ),
          );
        }
        return null;
      }
    }

    // 2. Fetch contacts with phone numbers
    if (!context.mounted) return null;
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );

    // Filter contacts with valid display names
    final validContacts = contacts.where((c) {
      final name = (c.displayName ?? '').trim();
      return name.isNotEmpty;
    }).toList();

    // Sort alphabetically
    validContacts.sort((a, b) =>
        (a.displayName ?? '').toLowerCase().compareTo((b.displayName ?? '').toLowerCase()));

    if (!context.mounted) return null;

    // 3. Open ContactPickerSheet modal
    return await showModalBottomSheet<List<ContactPickerResult>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContactPickerSheet(
        contacts: validContacts,
        existingNames: existingNames,
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load contacts: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }
}

/// Searchable modal bottom sheet to select contacts for a trip.
class ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  final List<String> existingNames;

  const ContactPickerSheet({
    super.key,
    required this.contacts,
    required this.existingNames,
  });

  @override
  State<ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<ContactPickerSheet> {
  final _searchController = TextEditingController();
  final Set<Contact> _selectedContacts = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isAlreadyAdded(Contact contact) {
    final name = (contact.displayName ?? '').trim().toLowerCase();
    return widget.existingNames.any((n) => n.trim().toLowerCase() == name);
  }

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return widget.contacts;
    final query = _searchQuery.toLowerCase();
    return widget.contacts.where((c) {
      final name = (c.displayName ?? '').toLowerCase();
      final hasPhone = c.phones.any((p) => p.number.replaceAll(RegExp(r'\s+'), '').contains(query));
      return name.contains(query) || hasPhone;
    }).toList();
  }

  Color _getAvatarColor(String name, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.indigo,
      Colors.teal,
      Colors.orange.shade700,
      Colors.pink.shade700,
      Colors.cyan.shade800,
    ];
    final hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = _filteredContacts;

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SafeArea(
          top: false,
          child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Select Contacts',
                    style: theme.textTheme.titleLarge?.copyWith(
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

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or number...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
            ),

            const Divider(height: 1),

            // Contacts List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No contacts found on device'
                                : 'No contacts matching "$_searchQuery"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        final contact = filtered[index];
                        final name = (contact.displayName ?? '').trim();
                        final phone = contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : null;
                        final alreadyAdded = _isAlreadyAdded(contact);
                        final isSelected = _selectedContacts.contains(contact);

                        final initials = name.isNotEmpty
                            ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                            : '?';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _getAvatarColor(name, theme.colorScheme),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: alreadyAdded
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                  : null,
                            ),
                          ),
                          subtitle: phone != null
                              ? Text(
                                  phone,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                          trailing: alreadyAdded
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'In trip',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : Checkbox(
                                  value: isSelected,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedContacts.add(contact);
                                      } else {
                                        _selectedContacts.remove(contact);
                                      }
                                    });
                                  },
                                ),
                          onTap: alreadyAdded
                              ? null
                              : () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedContacts.remove(contact);
                                    } else {
                                      _selectedContacts.add(contact);
                                    }
                                  });
                                },
                        );
                      },
                    ),
            ),

            // Bottom Confirmation Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedContacts.length} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selectedContacts.isEmpty
                        ? null
                        : () {
                            final results = _selectedContacts.map((c) {
                              return ContactPickerResult(
                                name: (c.displayName ?? '').trim(),
                                phoneNumber: c.phones.isNotEmpty
                                    ? c.phones.first.number
                                    : null,
                              );
                            }).toList();
                            Navigator.of(context).pop(results);
                          },
                    icon: const Icon(Icons.group_add_rounded, size: 18),
                    label: Text(
                      _selectedContacts.isEmpty
                          ? 'Add to trip'
                          : 'Add (${_selectedContacts.length}) to trip',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
