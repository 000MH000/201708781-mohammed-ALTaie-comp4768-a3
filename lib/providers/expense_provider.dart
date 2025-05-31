import 'package:flutter/material.dart'; // Needed for ChangeNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';

// This is the provider that will expose our ExpenseNotifier
final expenseProvider = ChangeNotifierProvider<ExpenseNotifier>((ref) {
  // You can access other providers here if needed, e.g., ref.watch(someOtherProvider)
  return ExpenseNotifier();
});

// The ChangeNotifier class that manages the state of expenses
class ExpenseNotifier extends ChangeNotifier {
  final HiveService _hiveService = HiveService(); // Instantiate HiveService
  List<Expense> _expenses = []; // Private list of expenses

  List<Expense> get expenses => _expenses; // Public getter for expenses

  ExpenseNotifier() {
    _loadExpenses(); // Load expenses when the provider is initialized
  }

  // Load expenses from Hive
  Future<void> _loadExpenses() async {
    _expenses = _hiveService.getExpenses();
    notifyListeners(); // Notify listeners (UI) that data has changed
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    await _hiveService.addExpense(expense);
    _expenses.add(expense); // Add to local list
    notifyListeners(); // Notify listeners
  }

  // Update an existing expense
  Future<void> updateExpense(Expense updatedExpense) async {
    await _hiveService.updateExpense(updatedExpense);
    // Find the index of the updated expense and replace it
    final index = _expenses.indexWhere((e) => e.key == updatedExpense.key);
    if (index != -1) {
      _expenses[index] = updatedExpense;
    }
    notifyListeners(); // Notify listeners
  }

  // Delete an expense
  Future<void> deleteExpense(Expense expense) async {
    await _hiveService.deleteExpense(expense);
    _expenses.removeWhere((e) => e.key == expense.key); // Remove from local list
    notifyListeners(); // Notify listeners
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