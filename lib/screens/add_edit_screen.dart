import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final String? expenseId; // Optional ID for editing

  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  ConsumerState<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  DateTime? _selectedDate;
  String? _selectedCategory;
  Expense? _currentExpense; // Holds the expense object if in edit mode

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Utilities',
    'Entertainment',
    'Rent',
    'Salary',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();

    // If expenseId is provided, we are in edit mode
    if (widget.expenseId != null) {
      // Find the expense from the provider using its Hive key
      // We need to read the provider to get the current state
      final expenseNotifier = ref.read(expenseProvider);
      _currentExpense = expenseNotifier.expenses.firstWhere(
            (e) => e.key.toString() == widget.expenseId,
        orElse: () => throw Exception('Expense not found for ID: ${widget.expenseId}'),
      );

      // Populate fields with existing expense data
      _descriptionController.text = _currentExpense!.description;
      _amountController.text = _currentExpense!.amount.toString();
      _selectedDate = _currentExpense!.date;
      _selectedCategory = _currentExpense!.category;
    } else {
      // Default for add mode
      _selectedDate = DateTime.now();
      _selectedCategory = _categories[0]; // Set default category
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Function to show the DatePicker
  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, now.month, now.day);
    final lastDate = DateTime(now.year + 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now, // Use selected date or current date
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to handle form submission (Add or Edit)
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved on TextFormFields

      final description = _descriptionController.text;
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final date = _selectedDate!;
      final category = _selectedCategory!;

      final expenseNotifier = ref.read(expenseProvider); // Read (not watch) provider for actions

      if (widget.expenseId == null) {
        // Add new expense
        final newExpense = Expense(
          description: description,
          amount: amount,
          date: date,
          category: category,
        );
        expenseNotifier.addExpense(newExpense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
      } else {
        // EDIT EXISTING EXPENSE - CORRECTED LOGIC HERE
        // Directly modify the properties of the _currentExpense object
        // which already has its Hive key.
        _currentExpense!.description = description;
        _currentExpense!.amount = amount;
        _currentExpense!.date = date;
        _currentExpense!.category = category;

        // Call updateExpense on the notifier, passing the modified _currentExpense
        expenseNotifier.updateExpense(_currentExpense!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated successfully!')),
        );
      }
      context.go('/list'); // Navigate back to the list screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.expenseId == null ? 'Add New Expense' : 'Edit Expense';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value)! <= 0) {
                    return 'Please enter a valid positive amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                  ),
                  IconButton(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(widget.expenseId == null ? 'Add Expense' : 'Update Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}