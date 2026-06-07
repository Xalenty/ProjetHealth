import 'dart:math' as math;

enum WeightProgressStatus {
  insufficientData,
  notStarted,
  progressing,
  almostReached,
  reached,
  movingAway,
}

class WeightProgress {
  final double startWeight;
  final double goalWeight;
  final double latestWeight;
  final double totalTargetChange;
  final double achievedChange;
  final double remainingChange;
  final double progressRatio;
  final WeightProgressStatus status;

  const WeightProgress({
    required this.startWeight,
    required this.goalWeight,
    required this.latestWeight,
    required this.totalTargetChange,
    required this.achievedChange,
    required this.remainingChange,
    required this.progressRatio,
    required this.status,
  });

  factory WeightProgress.calculate({
    required double startWeight,
    required double goalWeight,
    required double latestWeight,
  }) {
    final double totalTargetChange = (goalWeight - startWeight).abs();

    if (totalTargetChange == 0.0) {
      return WeightProgress(
        startWeight: startWeight,
        goalWeight: goalWeight,
        latestWeight: latestWeight,
        totalTargetChange: 0.0,
        achievedChange: 0.0,
        remainingChange: 0.0,
        progressRatio: 1.0,
        status: WeightProgressStatus.reached,
      );
    }

    final bool isWeightLossGoal = goalWeight < startWeight;
    final double achievedChange = isWeightLossGoal
        ? startWeight - latestWeight
        : latestWeight - startWeight;
    final double remainingChange = math.max(
      0.0,
      totalTargetChange - achievedChange,
    ).toDouble();
    final double progressRatio = (achievedChange / totalTargetChange)
        .clamp(0.0, 1.0)
        .toDouble();
    final bool hasReachedGoal = isWeightLossGoal
        ? latestWeight <= goalWeight
        : latestWeight >= goalWeight;

    final WeightProgressStatus status;

    if (hasReachedGoal) {
      status = WeightProgressStatus.reached;
    } else if (achievedChange < 0.0) {
      status = WeightProgressStatus.movingAway;
    } else if (progressRatio >= 0.8) {
      status = WeightProgressStatus.almostReached;
    } else if (progressRatio > 0.0) {
      status = WeightProgressStatus.progressing;
    } else {
      status = WeightProgressStatus.notStarted;
    }

    return WeightProgress(
      startWeight: startWeight,
      goalWeight: goalWeight,
      latestWeight: latestWeight,
      totalTargetChange: totalTargetChange,
      achievedChange: achievedChange,
      remainingChange: remainingChange,
      progressRatio: progressRatio,
      status: status,
    );
  }

  String get statusLabel {
    switch (status) {
      case WeightProgressStatus.insufficientData:
        return 'Données insuffisantes';
      case WeightProgressStatus.notStarted:
        return 'Progression non commencée';
      case WeightProgressStatus.progressing:
        return 'Progression en cours';
      case WeightProgressStatus.almostReached:
        return 'Objectif presque atteint';
      case WeightProgressStatus.reached:
        return 'Objectif atteint';
      case WeightProgressStatus.movingAway:
        return 'Évolution à surveiller';
    }
  }

  double get progressPercentage => progressRatio * 100;
}
