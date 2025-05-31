import 'package:flutter/material.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final String? expenseId; // Optional ID for editing

  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  Widget build(BuildContext context) {
    final String title = expenseId == null ? 'Add Expense' : 'Edit Expense';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          expenseId == null
              ? 'Add Expense Form - Coming Soon!'
              : 'Edit Expense Form for ID: $expenseId - Coming Soon!',
        ),
      ),
    );
  }
}