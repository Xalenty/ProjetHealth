import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final birthyearController = TextEditingController();
  final heightController = TextEditingController();
  final weightStartController = TextEditingController();
  final weightGoalController = TextEditingController();

  final AuthService authService = AuthService();

  bool obscurePassword = true;
  bool loading = false;
  bool isProfessional = false;

  String activityProfile = "sedentary";

  Future<void> register() async {
    setState(() => loading = true);

    try {
      await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        isProfessional: isProfessional,
      );

      if (!isProfessional) {
        final patientData = await authService.createPatientProfile(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          birthyear: int.parse(birthyearController.text.trim()),
          height: int.parse(heightController.text.trim()),
          weightStart: double.parse(weightStartController.text.trim()),
          weightGoal: double.parse(weightGoalController.text.trim()),
          activityProfile: activityProfile,
        );

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'patientId_${emailController.text.trim()}',
          patientData['id'].toString(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte créé avec succès"),
        ),
      );

      context.go('/login');
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.data.toString() ??
                "Erreur lors de la création du compte",
          ),
        ),
      );
    } catch (e) {
      print("ERREUR REGISTER: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    birthyearController.dispose();
    heightController.dispose();
    weightStartController.dispose();
    weightGoalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA7E8E1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 45,
                      color: Color(0xFF00796B),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Créer un compte",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Choisissez votre profil HealthFlow",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("Patient")),
                          selected: !isProfessional,
                          selectedColor: const Color(0xFFA7E8E1),
                          backgroundColor: Colors.white,
                          onSelected: (_) {
                            setState(() {
                              isProfessional = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("Médecin")),
                          selected: isProfessional,
                          selectedColor: const Color(0xFFA7E8E1),
                          backgroundColor: Colors.white,
                          onSelected: (_) {
                            setState(() {
                              isProfessional = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: firstNameController,
                    decoration: inputDecoration(
                      "Prénom",
                      Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: lastNameController,
                    decoration: inputDecoration(
                      "Nom",
                      Icons.badge_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecoration(
                      "Email",
                      Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: inputDecoration(
                      "Mot de passe",
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  if (!isProfessional) ...[
                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Informations patient",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: birthyearController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        "Année de naissance",
                        Icons.cake_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        "Taille en cm",
                        Icons.height,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: weightStartController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        "Poids actuel",
                        Icons.monitor_weight_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: weightGoalController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        "Objectif de poids",
                        Icons.flag_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: activityProfile,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: "sedentary",
                              child: Text("Sédentaire"),
                            ),
                            DropdownMenuItem(
                              value: "moderate",
                              child: Text("Modéré"),
                            ),
                            DropdownMenuItem(
                              value: "active",
                              child: Text("Actif"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              activityProfile = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        loading ? "Création..." : "Créer le compte",
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text(
                      "Déjà un compte ? Se connecter",
                      style: TextStyle(
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}