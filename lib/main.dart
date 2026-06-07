import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/psychic_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'router/app_router.dart';
import 'services/api_service.dart';

void main() {
  runApp(const HealthFlowApp());
}

class HealthFlowApp extends StatelessWidget {
  const HealthFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..restoreSession(),
        ),
      ChangeNotifierProvider(
  create: (_) => PsychicDataProvider(),
),
        ChangeNotifierProvider(
          create: (_) => PatientProvider(ApiService())..loadPatients(),
        ),
      ],

      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'HealthFlow',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
