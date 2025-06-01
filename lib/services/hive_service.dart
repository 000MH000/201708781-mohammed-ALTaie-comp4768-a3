// lib/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // No longer strictly needed here
import '../models/expense.dart'; // Import your Expense model

// If you want to keep this class, it now acts more as a wrapper around Hive.box
// rather than handling the global initialization/opening.
class HiveService {
  static const String _expenseBoxName = 'expenses'; // Keep for consistency

  // No longer needs an init() method if main.dart handles global init

  // Helper to get the already opened box
  Box<Expense> get _box {
    // This assumes Hive.openBox has already been called in main.dart
    return Hive.box<Expense>(_expenseBoxName);
  }

  // Get all expenses
  List<Expense> getExpenses() {
    return _box.values.toList();
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    await _box.add(expense);
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await expense.save();
  }

  // Delete an expense
  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
  }
}