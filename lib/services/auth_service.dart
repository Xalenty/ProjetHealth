import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://health.shrp.dev',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

// Conservation des id de rôle pour assigner le bon rôle a la création de compte

  static const String patientRole =
      '0777b505-b6cc-4308-9f17-c47fda65da29';

  static const String professionalRole =
      '16317dcf-1e2f-4fba-969f-6f6b15ba1062';

    


// requête API pour le login 
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data['data'];
  }

  // création de compte via requête API selon le rôle
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool isProfessional,
  }) async {
    final String roleId =
        isProfessional ? professionalRole : patientRole;

    await dio.post(
      '/users',
      data: {
        'role': roleId,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
  }


  Future<Map<String, dynamic>> createPatientProfile({
    required String firstName,
    required String lastName,
    required int birthyear,
    required int height,
    required double weightStart,
    required double weightGoal,
    required String activityProfile,
  }) async {
    final response = await dio.post(
      '/items/people',
      data: {
        'firstname': firstName,
        'lastname': lastName,
        'birthyear': birthyear,
        'height': height,
        'weight_start': weightStart,
        'weight_goal': weightGoal,
        'activity_profile': activityProfile,
      },
    );

    return response.data['data'];
  }

// Chargement des données psychiques via l'utilisation du jeton JWT dans un 
//header
  Future<Response> getPsychicData(String token) {
    return dio.get(
      '/items/psychicData',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}