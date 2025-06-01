import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <--- ADD THIS IMPORT
import '../models/expense.dart';
// import '../services/hive_service.dart'; // This import is no longer strictly needed if HiveService is unused by Notifier

// This is the provider that will expose our ExpenseNotifier
final expenseProvider = ChangeNotifierProvider<ExpenseNotifier>((ref) {
  return ExpenseNotifier();
});

// The ChangeNotifier class that manages the state of expenses
class ExpenseNotifier extends ChangeNotifier {
  // Removed explicit HiveService instance, accessing Hive.box directly
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseNotifier() {
    _loadExpenses(); // Load expenses when the provider is initialized
  }

  // Load expenses from Hive
  Future<void> _loadExpenses() async {
    final expenseBox = Hive.box<Expense>('expenses');
    _expenses = expenseBox.values.toList();
    notifyListeners();
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    final expenseBox = Hive.box<Expense>('expenses');
    await expenseBox.add(expense);
    await _loadExpenses();
  }

  // Update an existing expense
  Future<void> updateExpense(Expense updatedExpense) async {
    // Hive's .save() method on a HiveObject instance is enough to update it
    await updatedExpense.save();
    await _loadExpenses();
  }

  // Delete an expense
  Future<void> deleteExpense(Expense expense) async {
    // Hive's .delete() method on a HiveObject instance is enough to delete it
    await expense.delete();
    await _loadExpenses();
  }

  // Get expenses sorted by date for line chart
  List<Expense> get sortedExpensesByDate {
    final sortedList = List<Expense>.from(_expenses);
    sortedList.sort((a, b) => a.date.compareTo(b.date));
    return sortedList;
  }

  // Computed value for total spending
  double getTotalSpending() {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }
  // Computed value for spending by category (for Bar and Pie charts)
  Map<String, double> getSpendingByCategory() {
    final Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals.update(
        expense.category,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return categoryTotals;
  }

  // Method to get daily spending for Line Chart
  Map<DateTime, double> getDailySpending() {
    final Map<DateTime, double> dailyTotals = {};
    for (var expense in _expenses) {
      // Normalize date to just year, month, day for grouping
      final dateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals.update(
        dateOnly,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return dailyTotals;
  }
}