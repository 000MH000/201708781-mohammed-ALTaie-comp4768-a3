import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart'; // Required for Hive init
import 'services/hive_service.dart'; // Import your HiveService

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await _initHive(); // Initialize Hive before running the app
  runApp(const MyApp());
}

Future<void> _initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path); // Initialize Hive with a storage path
  // No need to register adapter here if HiveService.init() handles it.
  // We'll call HiveService().init() later which will register the adapter.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
        ),
        body: Center(
          child: Text('Welcome to Expense Tracker!'),
        ),
      ),
    );
  }
}