import 'package:flutter/material.dart';

import '../models/psychic_data.dart';
import '../providers/auth_provider.dart';

class PsychicDataProvider extends ChangeNotifier {
  List<PsychicData> psychicData = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadPsychicData(
    AuthProvider authProvider,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      final response =
          await authProvider.getPsychicData();

      final List data = response.data['data'];

      psychicData = data
          .map(
            (json) => PsychicData.fromJson(json),
          )
          .toList();

    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  List<PsychicData> getPatientPsychicData(
    String patientId,
  ) {
    return psychicData
        .where(
          (item) => item.peopleId == patientId,
        )
        .toList();
  }
}