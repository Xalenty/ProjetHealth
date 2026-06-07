import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isRestoring = true;
  String? accessToken;
  String? refreshToken;
  String? email;
  String? patientId;
  bool get isLoggedIn => accessToken != null;

  Future<void> login(String emailInput, String password) async {
    final data = await _authService.login(emailInput, password);
    
    accessToken = data['access_token'];
    refreshToken = data['refresh_token'];
    email = emailInput;
   


// Au login , enregistrement en local de l'acces Token, du refresh Token et de l'email
    final prefs = await SharedPreferences.getInstance();

patientId = prefs.getString('patientId_$emailInput');
    
    await prefs.setString('accessToken', accessToken!);
    await prefs.setString('refreshToken', refreshToken!);
    await prefs.setString('email', email!);

    notifyListeners();
  }


  // lors de le restoration de session on vérifie si les données sont non 
  //nulles
Future<void> restoreSession() async {
  final prefs = await SharedPreferences.getInstance();

  accessToken = prefs.getString('accessToken');
  refreshToken = prefs.getString('refreshToken');
  email = prefs.getString('email');
  patientId = prefs.getString('patientId_$email');

  isRestoring = false;
  notifyListeners();
}


// lors du logout , toutes les données sauvegardées sont égales a null
  Future<void> logout() async {
    accessToken = null;
    refreshToken = null;
    email = null;
    isRestoring = false;
    patientId=null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("patientId");
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('email');

    notifyListeners();
  }

  Future<Response> getPsychicData() async {
    if (accessToken == null) {
      throw Exception("Utilisateur non connecté");
    }

    return _authService.getPsychicData(accessToken!);
  }
}