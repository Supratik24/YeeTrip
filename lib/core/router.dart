import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/expenses/presentation/screens/add_edit_expense_screen.dart';
import '../features/trips/presentation/screens/trip_detail_scaffold.dart';
import '../features/trips/presentation/screens/trip_list_screen.dart';
import '../features/trips/presentation/screens/trip_setup_screen.dart';

/// App router configuration with go_router.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TripListScreen(),
      routes: [
        GoRoute(
          path: 'trips/new',
          builder: (context, state) => const TripSetupScreen(),
        ),
        GoRoute(
          path: 'trips/:id',
          builder: (context, state) {
            final tripId = state.pathParameters['id']!;
            return TripDetailScaffold(tripId: tripId);
          },
          routes: [
            GoRoute(
              path: 'expenses/new',
              builder: (context, state) {
                final tripId = state.pathParameters['id']!;
                return AddEditExpenseScreen(tripId: tripId);
              },
            ),
            GoRoute(
              path: 'expenses/:expenseId/edit',
              builder: (context, state) {
                final tripId = state.pathParameters['id']!;
                final expenseId = state.pathParameters['expenseId']!;
                return AddEditExpenseScreen(
                  tripId: tripId,
                  expenseId: expenseId,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page not found')),
    body: Center(
      child: Text('No route found for ${state.uri}'),
    ),
  ),
);
