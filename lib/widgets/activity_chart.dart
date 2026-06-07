import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/physical_activity.dart';

enum ActivityMetric { calories, duration, steps }

class ActivityChart extends StatefulWidget {
  final List<PhysicalActivity> activities;

  const ActivityChart({super.key, required this.activities});

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  ActivityMetric selectedMetric = ActivityMetric.calories;

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune activité physique disponible.'),
        ),
      );
    }

    final sortedActivities = [...widget.activities]
      ..sort((first, second) => second.date.compareTo(first.date));

    final recentActivities = sortedActivities
        .take(7)
        .toList()
        .reversed
        .toList();

    final values = recentActivities.map(_getMetricValue).toList();

    final maximumValue = values.reduce(max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activités récentes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Analyse des 7 dernières activités'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Calories'),
                  selected: selectedMetric == ActivityMetric.calories,
                  onSelected: (_) {
                    setState(() {
                      selectedMetric = ActivityMetric.calories;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Durée'),
                  selected: selectedMetric == ActivityMetric.duration,
                  onSelected: (_) {
                    setState(() {
                      selectedMetric = ActivityMetric.duration;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Pas'),
                  selected: selectedMetric == ActivityMetric.steps,
                  onSelected: (_) {
                    setState(() {
                      selectedMetric = ActivityMetric.steps;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (maximumValue <= 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aucune donnée disponible pour cette mesure.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: maximumValue * 1.2,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
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
                          reservedSize: 42,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= recentActivities.length) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat(
                                  'dd/MM',
                                ).format(recentActivities[index].date),
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: recentActivities.asMap().entries.map((entry) {
                      final value = _getMetricValue(entry.value);

                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              _getLegendText(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  double _getMetricValue(PhysicalActivity activity) {
    switch (selectedMetric) {
      case ActivityMetric.calories:
        return activity.consumedCalories.toDouble();
      case ActivityMetric.duration:
        return activity.duration.toDouble();
      case ActivityMetric.steps:
        return activity.numberOfSteps.toDouble();
    }
  }

  String _getLegendText() {
    switch (selectedMetric) {
      case ActivityMetric.calories:
        return 'Valeurs exprimées en kilocalories.';
      case ActivityMetric.duration:
        return 'Valeurs exprimées en minutes.';
      case ActivityMetric.steps:
        return 'Nombre de pas enregistrés.';
    }
  }
}
