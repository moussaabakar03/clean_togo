import 'package:clean_togo/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clean_togo/ui/dashboard/dashboard_screen.dart';
import 'package:clean_togo/ui/auth/register_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Contrôleurs pour récupérer la saisie
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedRole = 'Chauffeur';
  bool _isLoading = false;

  // Remplace ton _login()
  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token']; // Récupère le token renvoyé par Spring Security

        // STOCKER LE TOKEN (ex: avec flutter_secure_storage)
        // await storage.write(key: 'jwt', value: token);

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
      } else {
        _showError("Email ou mot de passe incorrect.");
      }
    } catch (e) {
      _showError("Erreur de connexion serveur.");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // 2. Fonction de connexion Firebase
  /*Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tentative de connexion
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si réussi, on va au Dashboard et on vide la pile de navigation
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs spécifiques (mauvais mot de passe, email inconnu, etc.)
      String message = "Une erreur est survenue";
      if (e.code == 'user-not-found') message = "Aucun utilisateur trouvé pour cet email.";
      else if (e.code == 'wrong-password') message = "Mot de passe incorrect.";
      else if (e.code == 'invalid-email') message = "Format d'email invalide.";

      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }*/

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC1FFB1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.recycling, size: 80, color: Color(0xFF006D32)),
              const Text("Clean Togo", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006D32))),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Text("Connectez-vous", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Email
                    _buildTextField(Icons.email_outlined, "Adresse Mail", "exemple@gmail.com", _emailController),
                    const SizedBox(height: 15),

                    // Password
                    _buildTextField(Icons.lock_outline, "Mot de passe", "••••••••", _passwordController, isObscure: true),
                    //const SizedBox(height: 20),

                    //_buildRoleSelector(),
                    const SizedBox(height: 30),

                    // Bouton de connexion avec indicateur de chargement
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E7E44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Se connecter", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                      child: const Text("Pas de compte ? S'inscrire", style: TextStyle(color: Color(0xFF1E7E44), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, String hint, TextEditingController controller, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 18), const SizedBox(width: 5), Text(label)]),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  /*Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Client', 'Chauffeur', 'Admin'].map((role) {
        bool isSelected = selectedRole == role;
        return ChoiceChip(
          label: Text(role),
          selected: isSelected,
          onSelected: (val) => setState(() => selectedRole = role),
          selectedColor: const Color(0xFF3498DB),
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }*/
}