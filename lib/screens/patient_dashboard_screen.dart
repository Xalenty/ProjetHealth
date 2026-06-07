import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  bool detailsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final patientProvider = context.read<PatientProvider>();

    if (!detailsLoaded && patientProvider.patients.isNotEmpty) {
      detailsLoaded = true;

      final patient = patientProvider.patients.first;

      Future.microtask(() {
        patientProvider.loadPatientById(patient.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final patientProvider = context.watch<PatientProvider>();

    //verif des données stockées et renvoi au login page si isLoggedIn est faux
    if (!authProvider.isLoggedIn) {
      Future.microtask(() {
        context.go('/login');
      });

      return const Scaffold(
        body: Center(
          child: Text("Utilisateur non connecté"),
        ),
      );
    }

    final patient = patientProvider.selectedPatient ??
        (patientProvider.patients.isNotEmpty
            ? patientProvider.patients.first
            : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        title: const Text("Mon espace santé"),
        actions: [
          // Button pr la déconnexion de compte
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: patient == null
          ? const Center(
              child: Text("Aucune donnée patient disponible."),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Bonjour ${patient.fullName}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Voici votre suivi personnel",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 24),

                _StatCard(
                  icon: Icons.monitor_weight_outlined,
                  title: "Dernier poids",
                  value: patientProvider.latestWeight != null
                      ? "${patientProvider.latestWeight!.toStringAsFixed(1)} kg"
                      : "Aucune donnée",
                ),

                const SizedBox(height: 12),

                _StatCard(
                  icon: Icons.flag_outlined,
                  title: "Objectif de poids",
                  value: "${patient.weightGoal} kg",
                ),

                const SizedBox(height: 12),

                _StatCard(
                  icon: Icons.directions_run,
                  title: "Activités physiques",
                  value: "${patientProvider.physicalActivities.length} activité(s)",
                ),

                const SizedBox(height: 20),

                _SimpleChartCard(
                  title: "Progression du suivi",
                  physiologicalCount:
                      patientProvider.physiologicalData.length,
                  activitiesCount:
                      patientProvider.physicalActivities.length,
                ),

                const SizedBox(height: 20),

                _AdviceCard(),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFA7E8E1),
          child: Icon(
            icon,
            color: const Color(0xFF00796B),
          ),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SimpleChartCard extends StatelessWidget {
  final String title;
  final int physiologicalCount;
  final int activitiesCount;

  const _SimpleChartCard({
    required this.title,
    required this.physiologicalCount,
    required this.activitiesCount,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      physiologicalCount,
      activitiesCount,
      1,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 20),

            _BarRow(
              label: "Poids",
              value: physiologicalCount,
              maxValue: maxValue,
            ),

            const SizedBox(height: 14),

            _BarRow(
              label: "Activités",
              value: activitiesCount,
              maxValue: maxValue,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const _BarRow({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final percent = maxValue == 0 ? 0.0 : value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label : $value relevé(s)"),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          minHeight: 12,
          backgroundColor: Colors.grey.shade200,
          color: const Color(0xFF00796B),
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA7E8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(
              Icons.lightbulb_outline,
              color: Color(0xFF00796B),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Continuez votre suivi régulièrement pour visualiser votre progression.",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}