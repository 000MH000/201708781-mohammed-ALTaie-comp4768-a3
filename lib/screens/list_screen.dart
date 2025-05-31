import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../providers/expense_provider.dart';
import '../models/expense.dart'; // Import Expense model

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the expenseProvider to get the list of expenses.
    // This will automatically rebuild the widget when expenses change.
    final expenseNotifier = ref.watch(expenseProvider);
    final List<Expense> expenses = expenseNotifier.expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              // TODO: Implement a way to navigate to charts (e.g., a chart selection screen or direct to bar chart for now)
              context.go('/charts/bar'); // Example: Navigate to bar chart
            },
          ),
        ],
      ),
      body: expenses.isEmpty
          ? const Center(
        child: Text(
          'No expenses added yet!\nTap the + button to add your first expense.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(expense.date), // Format date
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          expense.category,
                          style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          // Navigate to edit screen with expense ID (Hive key)
                          // GoRouter uses key directly for HiveObject
                          if (expense.key != null) {
                            context.go('/edit/${expense.key}');
                          } else {
                            // Handle case where expense doesn't have a key yet (shouldn't happen for saved expenses)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot edit unsaved expense.')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Confirm deletion (optional, but good UX)
                          _confirmDelete(context, expenseNotifier, expense);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add'); // Navigate to the add expense screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper function to show a confirmation dialog for deletion
  Future<void> _confirmDelete(
      BuildContext context, ExpenseNotifier expenseNotifier, Expense expense) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${expense.description}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                expenseNotifier.deleteExpense(expense);
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${expense.description}" deleted.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}