import 'package:go_router/go_router.dart';
import "package:health_flow/screens/register_screen.dart";
import "package:health_flow/screens/login_screen.dart";
import '../screens/patient_details_screen.dart';
import '../screens/patients_master_screen.dart';
import 'package:health_flow/screens/patient_dashboard_screen.dart';


// mise en place des routes et initatilisation de la page de login comme page
// d'accueil
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/patients',
      builder: (context, state) {
        return const PatientsMasterScreen();
      },
    ),
    GoRoute(
      path: '/patient-dashboard',
      builder: (context, state) {
        return const PatientDashboardScreen();
      },
    ),
    GoRoute(
      path: '/patients/:id',
      builder: (context, state) {
        final patientId = state.pathParameters['id']!;

        return PatientDetailsScreen(patientId: patientId);
      },
    ),
  ],
);
