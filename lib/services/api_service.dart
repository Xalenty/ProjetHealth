import 'package:dio/dio.dart';

import '../models/patient.dart';
import '../models/physical_activity.dart';
import '../models/physiological.dart';

class ApiService {
  // dio centralise les échanges avec l'API.
  // URL de base  qui permet ensuite d'utiliser uniquement les chemins des endpoints.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://health.shrp.dev',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // récupère tous les patients disponibles dans l'API.
  // Chaque objet JSON est ensuite converti en objet Patient.
  Future<List<Patient>> getPatients() async {
    final response = await _dio.get('/items/people');

    final data = _extractList(
      response.data,
      'la liste des patients',
    );

    return data
        .map(
          (json) => Patient.fromJson(
            _asMap(json),
          ),
        )
        .toList();
  }

  // récupère les informations détaillées d'un patient précis
  // à partir de son identifiant.
  Future<Patient> getPatientById(String id) async {
    final response = await _dio.get(
      '/items/people/$id',
    );

    final data = response.data['data'];

    return Patient.fromJson(
      _asMap(data),
    );
  }

  // récupère les données physiologiques d'un patient,
  // notamment son évolution de poids.
  Future<List<PhysiologicalData>>
      getPhysiologicalDataByPatientId(
    String patientId,
  ) async {
    final response = await _dio.get(
      '/items/physiologicalData',
      queryParameters: {
        //on demande uniquement les données du patient sélectionné.
        'filter[people_id][_eq]': patientId,

        //les relevés sont classés du plus ancien au plus récent
        //afin de tracer correctement la courbe d'évolution.
        'sort': 'date',
      },
    );

    final data = _extractList(
      response.data,
      'les données physiologiques',
    );

    return data
        .map(
          (json) => PhysiologicalData.fromJson(
            _asMap(json),
          ),
        )
        .toList();
  }

  //récupère l'historique des activités physiques du patient.
  Future<List<PhysicalActivity>>
      getPhysicalActivitiesByPatientId(
    String patientId,
  ) async {
    final response = await _dio.get(
      '/items/physicalActivities',
      queryParameters: {
        // comme pour les données physiologiques,
        // on filtre les résultats avec l'identifiant du patient.
        'filter[people_id][_eq]': patientId,

        // Le signe "-" permet d'afficher les activités
        // les plus récentes en premier.
        'sort': '-date',
      },
    );

    final data = _extractList(
      response.data,
      'les activités physiques',
    );

    return data
        .map(
          (json) => PhysicalActivity.fromJson(
            _asMap(json),
          ),
        )
        .toList();
  }

  // vérifie que la réponse reçue contient bien une liste dans la clé "data".
  List<dynamic> _extractList(
    dynamic responseData,
    String label,
  ) {
    final data = responseData is Map<String, dynamic>
        ? responseData['data']
        : null;

    if (data is! List) {
      throw Exception(
        'Format inattendu pour $label.',
      );
    }

    return data;
  }

  // vérifie qu'un élément JSON possède bien la structure attendue
  // avant de le transmettre au modèle Dart correspondant.
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Objet JSON inattendu reçu depuis l’API.',
      );
    }

    return data;
  }
}
