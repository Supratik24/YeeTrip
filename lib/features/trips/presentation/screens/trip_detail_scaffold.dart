import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/providers.dart';
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

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Budget',
              ),
              NavigationDestination(
                icon: Icon(Icons.handshake_outlined),
                selectedIcon: Icon(Icons.handshake),
                label: 'Settle',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
