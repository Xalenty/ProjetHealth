import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/physical_activity.dart';
import '../utils/display_helpers.dart';

class PhysicalActivityList extends StatefulWidget {
  final List<PhysicalActivity> activities;

  const PhysicalActivityList({super.key, required this.activities});

  @override
  State<PhysicalActivityList> createState() => _PhysicalActivityListState();
}

class _PhysicalActivityListState extends State<PhysicalActivityList> {
  bool showAllActivities = false;

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune activité physique enregistrée.'),
        ),
      );
    }

    final sortedActivities = [...widget.activities]
      ..sort((first, second) => second.date.compareTo(first.date));
    final displayedActivities = showAllActivities
        ? sortedActivities
        : sortedActivities.take(8).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique des activités',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${widget.activities.length} activité(s) enregistrée(s)'),
            const SizedBox(height: 12),
            ...displayedActivities.map(
              (activity) => _ActivityTile(activity: activity),
            ),
            if (widget.activities.length > 8) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      showAllActivities = !showAllActivities;
                    });
                  },
                  icon: Icon(
                    showAllActivities ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(
                    showAllActivities
                        ? 'Afficher moins'
                        : 'Afficher toutes les activités',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final PhysicalActivity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(_activityIcon(activity.type))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translateActivityType(activity.type),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd/MM/yyyy à HH:mm').format(activity.date)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _ActivityInfo(
                        icon: Icons.timer_outlined,
                        label: formatDurationMinutes(activity.duration),
                      ),
                      _ActivityInfo(
                        icon: Icons.local_fire_department_outlined,
                        label: '${activity.consumedCalories} kcal',
                      ),
                      if (activity.numberOfSteps > 0)
                        _ActivityInfo(
                          icon: Icons.directions_walk,
                          label: '${activity.numberOfSteps} pas',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String type) {
    switch (type.toLowerCase().trim()) {
      case 'bike':
      case 'cycling':
      case 'bicycle':
        return Icons.directions_bike;
      case 'walk':
      case 'walking':
        return Icons.directions_walk;
      case 'run':
      case 'running':
        return Icons.directions_run;
      case 'swim':
      case 'swimming':
        return Icons.pool;
      case 'hike':
      case 'hiking':
        return Icons.hiking;
      default:
        return Icons.fitness_center;
    }
  }
}

class _ActivityInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActivityInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
