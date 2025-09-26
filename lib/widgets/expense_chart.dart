import 'package:exprense_tracker/models/transaction.dart';
import 'package:exprense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    final expenses = transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .toList();

    final Map<String, double> categoryTotals = {};
    for (var transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    final categories = categoryTotals.keys.toList();
    final values = categoryTotals.values.toList();

    if (categories.isEmpty) {
      return const Center(child: Text('No hay gastos para mostrar'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: values.isEmpty
              ? 0
              : (values.reduce((a, b) => a > b ? a : b) * 1.2),
          barGroups: List.generate(categories.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.blue,
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(value.toInt().toString()),
                  );
                },
                interval: values.isNotEmpty
                    ? (values.reduce((a, b) => a > b ? a : b) / 4)
                    : 1,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // más espacio para evitar overflow
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= categories.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        categories[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
                interval: 1,
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
