import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'services/hive_service.dart';
import 'routing/app_router.dart'; // Import your AppRouter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive(); // Initialize Hive before running the app
  runApp(
    const ProviderScope( // Wrap your app with ProviderScope for Riverpod
      child: MyApp(),
    ),
  );
}

Future<void> _initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  // Initialize HiveService here and open the box
  await HiveService().init(); // Call the init method of your HiveService
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // Use MaterialApp.router for GoRouter
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: AppRouter.router, // Pass your GoRouter instance here
    );
  }
}