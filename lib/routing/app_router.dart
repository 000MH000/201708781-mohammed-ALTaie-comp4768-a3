// lib/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Import all your screens
import '../screens/list_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/chart_screens/bar_chart_screen.dart';
import '../screens/chart_screens/line_chart_screen.dart';
import '../screens/chart_screens/pie_chart_screen.dart';
import '../screens/chart_screens/chart_selection_screen.dart'; // <--- NEW IMPORT

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // static final _shellNavigatorKey = GlobalKey<NavigatorState>(); // Not strictly needed for this setup

  static final GoRouter router = GoRouter(
    initialLocation: '/list',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/list',
      ),
      GoRoute(
        path: '/list',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddEditExpenseScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final String? expenseId = state.pathParameters['id'];
          return AddEditExpenseScreen(expenseId: expenseId);
        },
      ),
      // NEW ROUTE for Chart Selection Screen
      GoRoute(
        path: '/charts', // This will now go to the selection screen
        builder: (context, state) => const ChartSelectionScreen(),
      ),
      // Individual chart routes remain children of charts for clear pathing if needed
      GoRoute(
        path: '/charts/bar', // Specific route for bar chart
        builder: (context, state) => const BarChartScreen(),
      ),
      GoRoute(
        path: '/charts/line', // Specific route for line chart
        builder: (context, state) => const LineChartScreen(),
      ),
      GoRoute(
        path: '/charts/pie', // Specific route for pie chart
        builder: (context, state) => const PieChartScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}