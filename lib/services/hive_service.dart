import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart'; // Import your Expense model

class HiveService {
  static const String _expenseBoxName = 'expenses';
  late Box<Expense> _expenseBox;

  // Initialize Hive and open the expense box
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) { // Check if adapter is not already registered
      Hive.registerAdapter(ExpenseAdapter()); // Register the generated adapter
    }
    _expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
  }

  // Get all expenses
  List<Expense> getExpenses() {
    return _expenseBox.values.toList();
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    await _expenseBox.add(expense);
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    // HiveObject has a key, which is useful for updating
    // If you need to update by an ID, you'd find the expense by ID first.
    // For now, assuming expense object passed already has its key if it's from the box
    await expense.save(); // Save method is available on HiveObject
  }

  // Delete an expense
  Future<void> deleteExpense(Expense expense) async {
    await expense.delete(); // Delete method is available on HiveObject
  }
}