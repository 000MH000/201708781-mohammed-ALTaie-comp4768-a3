import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routing/app_router.dart';
import 'models/expense.dart'; // <--- KEEP THIS IMPORT (Expense model and its adapter)

// REMOVE THIS LINE: import 'models/expense.g.dart'; // <--- THIS LINE MUST BE DELETED

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapter globally
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) { // Assuming ExpenseAdapter is typeId 0
    // ExpenseAdapter is available via the 'models/expense.dart' import
    Hive.registerAdapter(ExpenseAdapter());
  }
  // Open the box once globally
  await Hive.openBox<Expense>('expenses');

  runApp(
    const ProviderScope( // Wrap your app with ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: AppRouter.router,
    );
  }
}