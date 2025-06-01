// lib/screens/chart_screens/chart_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChartSelectionScreen extends StatelessWidget {
  const ChartSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Charts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/charts/bar');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60), // Make buttons larger
              ),
              child: const Text(
                'Bar Chart (Spending by Category)',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/charts/line');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
              ),
              child: const Text(
                'Line Chart (Spending Over Time)',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/charts/pie'); // Assuming you'll implement a Pie Chart
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
              ),
              child: const Text(
                'Pie Chart (Category Distribution)',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}