import 'package:flutter/material.dart';

import '../models/activity_summary.dart';
import '../models/patient.dart';
import '../models/physical_activity.dart';
import '../models/physiological.dart';
import '../models/weight_progress.dart';
import '../services/api_service.dart';

class PatientProvider extends ChangeNotifier {
  final ApiService apiService;

  PatientProvider(this.apiService);

  List<Patient> patients = [];
  bool isLoading = false;
  String? errorMessage;

  Patient? selectedPatient;
  List<PhysiologicalData> physiologicalData = [];
  List<PhysicalActivity> physicalActivities = [];

  bool isLoadingDetails = false;
  String? detailsErrorMessage;

  Future<void> loadPatients() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      patients = await apiService.getPatients();
    } catch (error) {
      debugPrint('Erreur lors du chargement des patients : $error');
      errorMessage = 'Impossible de récupérer les patients.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPatientById(String id) async {
    isLoadingDetails = true;
    detailsErrorMessage = null;
    selectedPatient = null;
    physiologicalData = [];
    physicalActivities = [];
    notifyListeners();

    try {
      selectedPatient = await apiService.getPatientById(id);
      physiologicalData = await apiService.getPhysiologicalDataByPatientId(id);
      physicalActivities = await apiService.getPhysicalActivitiesByPatientId(id);
    } catch (error) {
      debugPrint('Erreur lors du chargement des détails du patient : $error');
      detailsErrorMessage = 'Impossible de récupérer les détails du patient.';
    } finally {
      isLoadingDetails = false;
      notifyListeners();
    }
  }

  double? get latestWeight {
    if (physiologicalData.isEmpty) {
      return null;
    }

    final sortedData = [...physiologicalData]
      ..sort((first, second) => first.date.compareTo(second.date));

    return sortedData.last.weight;
  }

  WeightProgress? get weightProgress {
    final patient = selectedPatient;
    final currentWeight = latestWeight;

    if (patient == null ||
        currentWeight == null ||
        patient.weightStart <= 0 ||
        patient.weightGoal <= 0) {
      return null;
    }

    return WeightProgress.calculate(
      startWeight: patient.weightStart.toDouble(),
      goalWeight: patient.weightGoal.toDouble(),
      latestWeight: currentWeight,
    );
  }

  int get suspiciousWeightMeasurementCount {
    if (physiologicalData.length < 2) {
      return 0;
    }

    final sortedData = [...physiologicalData]
      ..sort((first, second) => first.date.compareTo(second.date));

    int count = 0;

    for (int index = 1; index < sortedData.length; index++) {
      final difference =
          (sortedData[index].weight - sortedData[index - 1].weight).abs();

      if (difference > 5.0) {
        count++;
      }
    }

    return count;
  }

  bool get latestWeightMeasurementIsSuspicious {
    if (physiologicalData.length < 2) {
      return false;
    }

    final sortedData = [...physiologicalData]
      ..sort((first, second) => first.date.compareTo(second.date));

    final latestDifference =
        (sortedData.last.weight - sortedData[sortedData.length - 2].weight)
            .abs();

    return latestDifference > 5.0;
  }

  ActivitySummary get activitySummary {
    if (physicalActivities.isEmpty) {
      return const ActivitySummary(
        activityCount: 0,
        totalCalories: 0,
        totalDuration: 0,
        totalSteps: 0,
        averageCalories: 0.0,
        mostFrequentActivityType: 'unknown',
      );
    }

    int totalCalories = 0;
    int totalDuration = 0;
    int totalSteps = 0;
    final Map<String, int> activityTypeCounts = {};

    for (final activity in physicalActivities) {
      totalCalories += activity.consumedCalories;
      totalDuration += activity.duration;
      totalSteps += activity.numberOfSteps;

      final normalizedType = activity.type.toLowerCase().trim();

      activityTypeCounts.update(
        normalizedType,
        (currentCount) => currentCount + 1,
        ifAbsent: () => 1,
      );
    }

    final mostFrequentActivityType = activityTypeCounts.entries
        .reduce((first, second) => first.value >= second.value ? first : second)
        .key;

    return ActivitySummary(
      activityCount: physicalActivities.length,
      totalCalories: totalCalories,
      totalDuration: totalDuration,
      totalSteps: totalSteps,
      averageCalories: totalCalories / physicalActivities.length,
      mostFrequentActivityType: mostFrequentActivityType,
    );
  }
}
