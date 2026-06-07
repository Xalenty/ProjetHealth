class ActivitySummary {
  final int activityCount;
  final int totalCalories;
  final int totalDuration;
  final int totalSteps;
  final double averageCalories;
  final String mostFrequentActivityType;

  const ActivitySummary({
    required this.activityCount,
    required this.totalCalories,
    required this.totalDuration,
    required this.totalSteps,
    required this.averageCalories,
    required this.mostFrequentActivityType,
  });

  bool get hasActivities => activityCount > 0;
}
