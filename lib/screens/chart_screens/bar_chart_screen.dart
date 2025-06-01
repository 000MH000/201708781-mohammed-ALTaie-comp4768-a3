import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Make sure this is imported

import '../../providers/expense_provider.dart';

class BarChartScreen extends ConsumerWidget {
  const BarChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseNotifier = ref.watch(expenseProvider);
    final Map<String, double> categorySpending = expenseNotifier.getSpendingByCategory();

    final List<BarChartGroupData> barGroups = [];
    final List<String> categories = categorySpending.keys.toList();
    categories.sort();

    if (categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spending by Category (Bar Chart)'),
          // --- ADD THIS LEADING BUTTON ---
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Standard back arrow icon
            onPressed: () {
              // This navigates directly to the list screen,
              // effectively clearing the chart screens from the navigation stack.
              context.go('/list');
            },
          ),),
        body: const Center(
          child: Text('No expenses to display in the bar chart yet!'),
        ),
      );
    }

    final Map<String, int> categoryIndexes = {
      for (var i = 0; i < categories.length; i++) categories[i]: i
    };

    for (var category in categories) {
      final int x = categoryIndexes[category]!;
      final double y = categorySpending[category]!;
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: y,
              color: Colors.blueAccent,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending by Category'),
        // --- ADD THIS LEADING BUTTON ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Standard back arrow icon
          onPressed: () {
            // This navigates directly to the list screen,
            // effectively clearing the chart screens from the navigation stack.
            context.go('/list');
          },
        ),
        // ------------------------------
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categorySpending.isEmpty
            ? const Center(
          child: Text('Add some expenses to see the bar chart!'),
        )
            : BarChart(
          BarChartData(
            barGroups: barGroups,
            borderData: FlBorderData(
              show: false,
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) { // <-- STILL TitleMeta is required
                    if (value.toInt() < 0 || value.toInt() >= categories.length) {
                      return const Text('');
                    }
                    // DIRECTLY RETURN TEXT, AVOID SideTitleWidget
                    return Text(
                      categories[value.toInt()],
                      style: const TextStyle(
                          color: Colors.black, fontSize: 10),
                      textAlign: TextAlign.center,
                    );
                  },
                  interval: 1,
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) { // <-- STILL TitleMeta is required
                    return Text('\$${value.toStringAsFixed(0)}');
                  },
                  reservedSize: 40,
                  interval: (categorySpending.values.isNotEmpty && categorySpending.values.reduce((a, b) => a > b ? a : b) > 0)
                      ? (categorySpending.values.reduce((a, b) => a > b ? a : b) / 4).ceilToDouble()
                      : 25,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                  final String category = categories[group.x.toInt()];
                  return BarTooltipItem(
                    '$category\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\$${rod.toY.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}