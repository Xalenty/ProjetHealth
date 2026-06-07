import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_summary.dart';
import '../models/patient.dart';
import '../models/physical_activity.dart';
import '../models/physiological.dart';
import '../models/weight_progress.dart';
import '../providers/patient_provider.dart';
import '../utils/display_helpers.dart';
import '../widgets/activity_chart.dart';
import '../widgets/physical_activity_list.dart';
import '../widgets/section_card.dart'; // Import de nos nouveaux widgets UI
import '../widgets/weight_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/psychic_provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatientById(widget.patientId);
    });
      context.read<PsychicDataProvider>().loadPsychicData(
          context.read<AuthProvider>(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();

    return Scaffold(
      backgroundColor:
          Colors.grey.shade50, 
      appBar: AppBar(
        title: const Text(
          'Détails du patient',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(patientProvider),
    );
  }

  Widget _buildBody(PatientProvider patientProvider) {
    if (patientProvider.isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    if (patientProvider.detailsErrorMessage != null) {
      return _DetailsErrorView(
        message: patientProvider.detailsErrorMessage!,
        onRetry: () {
          patientProvider.loadPatientById(widget.patientId);
        },
      );
    }

    final patient = patientProvider.selectedPatient;

    if (patient == null) {
      return const Center(
        child: Text(
          'Aucun patient sélectionné.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return _PatientDetailsContent(
      patient: patient,
      physiologicalData: patientProvider.physiologicalData,
      physicalActivities: patientProvider.physicalActivities,
      physiologicalDataCount: patientProvider.physiologicalData.length,
      physicalActivitiesCount: patientProvider.physicalActivities.length,
      latestWeight: patientProvider.latestWeight,
      weightProgress: patientProvider.weightProgress,
      suspiciousWeightMeasurementCount:
          patientProvider.suspiciousWeightMeasurementCount,
      latestWeightMeasurementIsSuspicious:
          patientProvider.latestWeightMeasurementIsSuspicious,
      activitySummary: patientProvider.activitySummary,
    );
  }
}

class _PatientDetailsContent extends StatelessWidget {
  final Patient patient;
  final List<PhysiologicalData> physiologicalData;
  final List<PhysicalActivity> physicalActivities;
  final int physiologicalDataCount;
  final int physicalActivitiesCount;
  final double? latestWeight;
  final WeightProgress? weightProgress;
  final int suspiciousWeightMeasurementCount;
  final bool latestWeightMeasurementIsSuspicious;
  final ActivitySummary activitySummary;

  const _PatientDetailsContent({
    required this.patient,
    required this.physiologicalData,
    required this.physicalActivities,
    required this.physiologicalDataCount,
    required this.physicalActivitiesCount,
    required this.latestWeight,
    required this.weightProgress,
    required this.suspiciousWeightMeasurementCount,
    required this.latestWeightMeasurementIsSuspicious,
    required this.activitySummary,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildGeneralInformationCard(),
        _buildWeightCard(),
        _buildBmiCard(),
        _buildTrackingCard(),
        _buildProgressCard(),
        _buildActivitySummaryCard(),

        if (physiologicalData.isNotEmpty) ...[
          WeightChart(
            data: physiologicalData,
            targetWeight: patient.weightGoal > 0
                ? patient.weightGoal.toDouble()
                : null,
          ),
          const SizedBox(height: 16),
        ],

        if (physicalActivities.isNotEmpty) ...[
          ActivityChart(activities: physicalActivities),
          const SizedBox(height: 16),
          PhysicalActivityList(activities: physicalActivities),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            patient.firstname.isNotEmpty
                ? patient.firstname[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          patient.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          translateActivityProfile(patient.activityProfile),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (patient.isIncomplete) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Profil incomplet',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGeneralInformationCard() {
    return SectionCard(
      title: 'Informations générales',
      children: [
        InfoRow(
          icon: Icons.cake_outlined,
          label: 'Âge',
          value: patient.birthyear > 0 ? '${patient.age} ans' : 'Non renseigné',
        ),
        InfoRow(
          icon: Icons.height,
          label: 'Taille',
          value: patient.height > 0 ? '${patient.height} cm' : 'Non renseignée',
        ),
        InfoRow(
          icon: Icons.directions_run,
          label: 'Profil d’activité',
          value: translateActivityProfile(patient.activityProfile),
        ),
      ],
    );
  }

  Widget _buildWeightCard() {
    return SectionCard(
      title: 'Objectif de poids',
      children: [
        InfoRow(
          icon: Icons.monitor_weight_outlined,
          label: 'Poids de départ',
          value: patient.weightStart > 0
              ? '${patient.weightStart} kg'
              : 'Non renseigné',
        ),
        InfoRow(
          icon: Icons.flag_outlined,
          label: 'Objectif',
          value: patient.weightGoal > 0
              ? '${patient.weightGoal} kg'
              : 'Non renseigné',
        ),
        InfoRow(
          icon: Icons.swap_vert,
          label: 'Différence',
          value: patient.weightStart > 0 && patient.weightGoal > 0
              ? '${patient.weightDifference} kg'
              : 'Non calculable',
        ),
      ],
    );
  }

  Widget _buildBmiCard() {
    return SectionCard(
      title: 'IMC',
      children: [
        InfoRow(
          icon: Icons.analytics_outlined,
          label: 'Situation initiale',
          value: translateBmiStatus(patient.bmiStart),
        ),
        InfoRow(
          icon: Icons.track_changes_outlined,
          label: 'Objectif',
          value: translateBmiStatus(patient.bmiGoal),
        ),
      ],
    );
  }

  Widget _buildTrackingCard() {
    return SectionCard(
      title: 'Suivi disponible',
      children: [
        InfoRow(
          icon: Icons.show_chart,
          label: 'Mesures de poids',
          value: '$physiologicalDataCount relevé(s)',
        ),
        InfoRow(
          icon: Icons.monitor_weight_outlined,
          label: 'Dernier poids mesuré',
          value: latestWeight != null
              ? '${latestWeight!.toStringAsFixed(1)} kg'
              : 'Aucune donnée',
        ),
        InfoRow(
          icon: Icons.directions_run,
          label: 'Activités physiques',
          value: '$physicalActivitiesCount activité(s)',
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final progress = weightProgress;

    if (progress == null) {
      return const SectionCard(
        title: 'Progression vers l’objectif',
        children: [
          InfoRow(
            icon: Icons.info_outline,
            label: 'Statut',
            value: 'Données insuffisantes',
            iconColor: Colors.orange,
          ),
        ],
      );
    }

    final statusLabel = latestWeightMeasurementIsSuspicious &&
            progress.status == WeightProgressStatus.reached
        ? 'Objectif à vérifier'
        : progress.statusLabel;

    return SectionCard(
      title: 'Progression vers l’objectif',
      children: [
        InfoRow(
          icon: Icons.track_changes_outlined,
          label: 'Statut',
          value: statusLabel,
          iconColor: progress.status == WeightProgressStatus.reached
              ? Colors.green
              : Colors.blue,
        ),
        InfoRow(
          icon: Icons.percent,
          label: 'Progression',
          value: '${progress.progressPercentage.toStringAsFixed(0)} %',
        ),
        InfoRow(
          icon: Icons.trending_up,
          label: 'Évolution vers l’objectif',
          value: '${progress.achievedChange.toStringAsFixed(1)} kg',
        ),
        InfoRow(
          icon: Icons.flag_outlined,
          label: 'Reste à atteindre',
          value: '${progress.remainingChange.toStringAsFixed(1)} kg',
        ),
        if (suspiciousWeightMeasurementCount > 0)
          InfoRow(
            icon: Icons.warning_amber,
            label: 'Variations inhabituelles',
            value: '$suspiciousWeightMeasurementCount détectée(s)',
            iconColor: Colors.orange,
          ),
        if (latestWeightMeasurementIsSuspicious)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Le dernier relevé présente une variation importante. Vérifiez la mesure.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.progressRatio,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: progress.status == WeightProgressStatus.reached
                  ? Colors.green
                  : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySummaryCard() {
    if (!activitySummary.hasActivities) {
      return const SectionCard(
        title: 'Résumé des activités',
        children: [
          InfoRow(
            icon: Icons.info_outline,
            label: 'Statut',
            value: 'Aucune activité enregistrée',
          ),
        ],
      );
    }

    return SectionCard(
      title: 'Résumé des activités',
      children: [
        InfoRow(
          icon: Icons.directions_run,
          label: 'Activité dominante',
          value: translateActivityType(
            activitySummary.mostFrequentActivityType,
          ),
        ),
        InfoRow(
          icon: Icons.list_alt,
          label: 'Nombre total',
          value: '${activitySummary.activityCount}',
        ),
        InfoRow(
          icon: Icons.timer_outlined,
          label: 'Durée cumulée',
          value: formatDurationMinutes(activitySummary.totalDuration),
        ),
        InfoRow(
          icon: Icons.local_fire_department_outlined,
          label: 'Calories totales',
          value: '${activitySummary.totalCalories} kcal',
        ),
        InfoRow(
          icon: Icons.directions_walk,
          label: 'Nombre total de pas',
          value: '${activitySummary.totalSteps}',
        ),
        InfoRow(
          icon: Icons.analytics_outlined,
          label: 'Moyenne par activité',
          value: '${activitySummary.averageCalories.toStringAsFixed(1)} kcal',
        ),
      ],
    );
  }
}


class _DetailsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
