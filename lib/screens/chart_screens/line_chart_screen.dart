import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/expense_provider.dart';

class LineChartScreen extends ConsumerWidget {
  const LineChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseNotifier = ref.watch(expenseProvider);
    final Map<DateTime, double> dailySpending = expenseNotifier.getDailySpending();

    if (dailySpending.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Spending Over Time (Line Chart)')),
        body: const Center(
          child: Text('No expenses to display in the line chart yet!'),
        ),
      );
    }

    final List<DateTime> sortedDates = dailySpending.keys.toList()..sort();

    final List<FlSpot> spots = [];
    double minX = 0, maxX = 0, minY = 0, maxY = 0;

    if (sortedDates.isNotEmpty) {
      minX = sortedDates.first.millisecondsSinceEpoch.toDouble();
      maxX = sortedDates.last.millisecondsSinceEpoch.toDouble();
      minY = 0;
      maxY = dailySpending.values.reduce((a, b) => a > b ? a : b);

      for (int i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        spots.add(FlSpot(
          date.millisecondsSinceEpoch.toDouble(),
          dailySpending[date]!,
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Over Time (Line Chart)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY * 1.2,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (maxX - minX) / 3, // Roughly 4 labels, adjust as needed
                  getTitlesWidget: (double value, TitleMeta meta) { // <-- Explicitly specify types and use TitleMeta
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return SideTitleWidget(
                      axisSide: meta.axisSide, // <-- Use meta.axisSide
                      space: 8.0,
                      child: Text(
                        DateFormat.Md().format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) { // <-- Explicitly specify types and use TitleMeta
                    return Text('\$${value.toStringAsFixed(0)}');
                  },
                  reservedSize: 40,
                  interval: (maxY * 1.2) / 4,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.deepPurple,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                // In fl_chart ^1.0.0, tooltipBgColor is gone from here.
                // You would typically use `tooltipResolver` or set `tooltipStyle` on `LineTooltipItem`
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final FlSpot spot = touchedSpot;
                    final DateTime date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                    return LineTooltipItem(
                      '${DateFormat.yMd().format(date)}\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '\$${spot.y.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      // tooltipStyle: const TooltipStyle(backgroundColor: Colors.blueGrey),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}