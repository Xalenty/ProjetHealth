import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/physiological.dart';

class WeightChart extends StatelessWidget {
  final List<PhysiologicalData> data;
  final double? targetWeight;

  const WeightChart({
    super.key,
    required this.data,
    required this.targetWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune donnée de poids disponible.'),
        ),
      );
    }

    final sortedData = [...data]
      ..sort((first, second) => first.date.compareTo(second.date));

    final spots = sortedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final measuredWeights = sortedData.map((item) => item.weight).toList();

    final minimumMeasuredWeight = measuredWeights.reduce(min);
    final maximumMeasuredWeight = measuredWeights.reduce(max);

    final weightsDisplayedOnAxis = [...measuredWeights];

    if (targetWeight != null && targetWeight! > 0) {
      weightsDisplayedOnAxis.add(targetWeight!);
    }

    final minY = weightsDisplayedOnAxis.reduce(min) - 2;
    final maxY = weightsDisplayedOnAxis.reduce(max) + 2;

    final maxX = max(1, sortedData.length - 1).toDouble();

    final chartColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution du poids',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${sortedData.length} relevé(s) • '
              '${minimumMeasuredWeight.toStringAsFixed(1)} à '
              '${maximumMeasuredWeight.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)} kg',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();

                          final shouldDisplayDate =
                              index == 0 ||
                              index == sortedData.length ~/ 2 ||
                              index == sortedData.length - 1;

                          if (!shouldDisplayDate ||
                              index < 0 ||
                              index >= sortedData.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat(
                                'dd/MM',
                              ).format(sortedData[index].date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      if (targetWeight != null && targetWeight! > 0)
                        HorizontalLine(
                          y: targetWeight!,
                          color: Theme.of(context).colorScheme.secondary,
                          strokeWidth: 2,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            labelResolver: (_) {
                              return 'Objectif : '
                                  '${targetWeight!.toStringAsFixed(1)} kg';
                            },
                          ),
                        ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: chartColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: chartColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendItem(icon: Icons.show_chart, label: 'Poids mesuré'),
                _LegendItem(icon: Icons.horizontal_rule, label: 'Objectif'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LegendItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
    );
  }
}
