import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart'; // Needed for MaterialPage

// Import placeholder screens for now. We'll create these files later.
import '../screens/list_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/chart_screens/bar_chart_screen.dart';
import '../screens/chart_screens/line_chart_screen.dart';
import '../screens/chart_screens/pie_chart_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/list', // Set the initial route for the app
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Main screen (list of expenses)
      GoRoute(
        path: '/',
        redirect: (_, __) => '/list', // Redirect root to list screen
      ),
      GoRoute(
        path: '/list',
        builder: (context, state) => const ExpenseListScreen(),
      ),

      // Add Expense screen
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddEditExpenseScreen(),
      ),

      // Edit Expense screen (takes an optional ID parameter)
      GoRoute(
        path: '/edit/:id', // :id is a path parameter
        builder: (context, state) {
          final String? expenseId = state.pathParameters['id'];
          // For now, we'll pass null if ID isn't provided or not needed.
          // We'll refine this when we implement the actual edit logic.
          return AddEditExpenseScreen(expenseId: expenseId);
        },
      ),

      // Chart screens
      GoRoute(
        path: '/charts/bar',
        builder: (context, state) => const BarChartScreen(),
      ),
      GoRoute(
        path: '/charts/line',
        builder: (context, state) => const LineChartScreen(),
      ),
      GoRoute(
        path: '/charts/pie',
        builder: (context, state) => const PieChartScreen(),
      ),
    ],
    // Optional: Error screen or redirect for unknown routes
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}