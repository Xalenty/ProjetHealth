import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/patient_card.dart';

class PatientsMasterScreen extends StatefulWidget {
  const PatientsMasterScreen({super.key});

  @override
  State<PatientsMasterScreen> createState() => _PatientsMasterScreenState();
}

class _PatientsMasterScreenState extends State<PatientsMasterScreen> {
  bool hideIncompleteProfiles = false;
  String searchQuery = '';
  bool patientsPrinted = false;

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isRestoring) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

   // Verification des informations stockées : si utilisateur non connecté renvoi
   // à la login page
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

    if (!patientsPrinted && patientProvider.patients.isNotEmpty) {
      patientsPrinted = true;

      for (final patient in patientProvider.patients) {
        print(
          '${patient.id} | ${patient.fullName} | ${patient.age} ans | ${patient.height} cm | objectif ${patient.weightGoal} kg',
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors
          .grey
          .shade50, 
      appBar: AppBar(
        title: const Text('HealthFlow',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Buttons en haut a droite pour actualiser la page et se deconnecter
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: patientProvider.isLoading
                ? null
                : () {
                    patientProvider.loadPatients();
                  },
            icon: const Icon(Icons.refresh)),
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
      body: _buildBody(patientProvider),
    );
  }

  Widget _buildBody(PatientProvider patientProvider) {
    if (patientProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (patientProvider.errorMessage != null) {
      return _MasterErrorView(
        message: patientProvider.errorMessage!,
        onRetry: patientProvider.loadPatients,
      );
    }

    final incompleteCount = patientProvider.patients
        .where((p) => p.isIncomplete)
        .length;
    final completeCount = patientProvider.patients.length - incompleteCount;
    final normalizedQuery = searchQuery.trim().toLowerCase();

    final visiblePatients = patientProvider.patients.where((patient) {
      final matchesIncompleteFilter =
          !hideIncompleteProfiles || !patient.isIncomplete;
      final matchesSearch = normalizedQuery.isEmpty ||
          patient.fullName.toLowerCase().contains(normalizedQuery);

      return matchesIncompleteFilter && matchesSearch;
    }).toList();

    return Column(
      children: [
        // En-tête : Statistiques, Recherche et Filtre
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Ligne des statistiques rapides
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'Total',
                    patientProvider.patients.length.toString(),
                    Colors.blue.shade700,
                  ),
                  _buildStatItem(
                    'Complets',
                    completeCount.toString(),
                    Colors.green.shade700,
                  ),
                  _buildStatItem(
                    'Incomplets',
                    incompleteCount.toString(),
                    Colors.orange.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barre de recherche
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 8),

              // Switch des profils incomplets
              SwitchListTile(
                title: const Text(
                  'Masquer les profils incomplets',
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                value: hideIncompleteProfiles,
                onChanged: (value) {
                  setState(() {
                    hideIncompleteProfiles = value;
                  });
                },
              ),
            ],
          ),
        ),

        // Liste des cartes de patients
        Expanded(
          child: visiblePatients.isEmpty
              ? const _EmptyPatientsView()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: visiblePatients.length,
                  itemBuilder: (context, index) {
                    final patient = visiblePatients[index];
                    return PatientCard(
                      patient: patient,
                      onTap: () {
                        context.push('/patients/${patient.id}');
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Petit widget d'aide pour l'en-tête des statistiques
  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyPatientsView extends StatelessWidget {
  const _EmptyPatientsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun patient ne correspond aux critères.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MasterErrorView({required this.message, required this.onRetry});

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
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

