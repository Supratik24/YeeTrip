import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../budget/presentation/screens/budget_sliders_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../expenses/presentation/screens/expense_list_screen.dart';
import '../../../settle/presentation/screens/settle_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Main tab scaffold for a selected trip.
class TripDetailScaffold extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailScaffold({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripDetailScaffold> createState() => _TripDetailScaffoldState();
}

class _TripDetailScaffoldState extends ConsumerState<TripDetailScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Trip')),
        body: Center(child: Text('Error loading trip: $err')),
      ),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip not found')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('This trip does not exist or was deleted.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go home'),
                  ),
                ],
              ),
            ),
          );
        }

        final pages = [
          DashboardScreen(trip: trip),
          ExpenseListScreen(trip: trip),
          BudgetSlidersScreen(trip: trip),
          SettleScreen(trip: trip),
          SettingsScreen(trip: trip),
        ];

        final l10n = AppLocalizations.of(context);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n?.dashboardTab ?? 'Dashboard',
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: l10n?.expensesTab ?? 'Expenses',
              ),
              NavigationDestination(
                icon: const Icon(Icons.tune_outlined),
                selectedIcon: const Icon(Icons.tune),
                label: l10n?.budgetTab ?? 'Budget',
              ),
              NavigationDestination(
                icon: const Icon(Icons.handshake_outlined),
                selectedIcon: const Icon(Icons.handshake),
                label: l10n?.settleTab ?? 'Settle',
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n?.settingsTab ?? 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
