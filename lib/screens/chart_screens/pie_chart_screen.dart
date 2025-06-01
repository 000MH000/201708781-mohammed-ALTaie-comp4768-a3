import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation

import '../../providers/expense_provider.dart';

class PieChartScreen extends ConsumerWidget {
  const PieChartScreen({super.key});

  // A simple list of colors for the pie chart slices
  final List<Color> pieColors = const [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseNotifier = ref.watch(expenseProvider);
    final Map<String, double> categorySpending = expenseNotifier.getSpendingByCategory();
    final double totalSpending = expenseNotifier.getTotalSpending();

    if (categorySpending.isEmpty || totalSpending == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Category Distribution (Pie Chart)'),
          leading: IconButton( // Added leading button for navigation
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/list'); // Navigate directly to the main expense list
            },
          ),
        ),
        body: const Center(
          child: Text('No expenses to display in the pie chart yet!'),
        ),
      );
    }

    // Prepare data for the PieChart
    int colorIndex = 0;
    final List<PieChartSectionData> sections = categorySpending.entries.map((entry) {
      final double value = entry.value;
      final String category = entry.key;
      final double percentage = (value / totalSpending) * 100;

      final Color sectionColor = pieColors[colorIndex % pieColors.length];
      colorIndex++; // Cycle through colors

      return PieChartSectionData(
        color: sectionColor,
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _Badge(
          category,
          size: 20,
          borderColor: sectionColor,
        ),
        badgePositionPercentageOffset: 1.1, // Position the badge outside
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Distribution (Pie Chart)'),
        leading: IconButton( // Added leading button for navigation
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/list'); // Navigate directly to the main expense list
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2, // Space between sections
                  centerSpaceRadius: 40, // Size of the hole in the middle
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Optional: Add touch interaction if needed
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Spending: \$${totalSpending.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Legend for categories and colors
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: categorySpending.entries.map((entry) {
                final String category = entry.key;
                final int entryIndex = categorySpending.keys.toList().indexOf(category);
                final Color legendColor = pieColors[entryIndex % pieColors.length];
                return _LegendItem(color: legendColor, text: category);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for Pie Chart section labels (category text inside circle)
class _Badge extends StatelessWidget {
  const _Badge(
      this.text, {
        required this.size,
        required this.borderColor,
      });

  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          text[0].toUpperCase(), // Just the first letter of the category
          style: TextStyle(
            color: borderColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Helper widget for the legend
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}