import 'package:clean_togo/ui/auth/register_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Chauffeur'; // Rôle par défaut selon ta maquette

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC1FFB1), // Le vert clair du fond
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Logo Clean Togo (Placeholder)
              const Icon(Icons.recycling, size: 80, color: Color(0xFF006D32)),
              const Text("Clean Togo", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006D32))),
              const SizedBox(height: 30),

              // Carte blanche de connexion
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Text("Connectez vous", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 20),
                    _buildTextField(Icons.email_outlined, "Adresse Mail", "exemple@gmail.com"),
                    const SizedBox(height: 15),
                    _buildTextField(Icons.lock_outline, "Mot de passe", "..........", isObscure: true),
                    const SizedBox(height: 20),

                    const Text("En tant que :", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                    _buildRoleSelector(),

                    const SizedBox(height: 30),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      //onPressed: () => _login(),
                      onPressed: () => {},
                      child: const Text("Se connecter"),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vous n'avez de compte ? ", style: TextStyle(fontSize: 12)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                          child: const Text("S'inscrire", style: TextStyle(color: Color(0xFF1E7E44), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
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

  // Widget pour les champs de saisie
  Widget _buildTextField(IconData icon, String label, String hint, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 18), const SizedBox(width: 5), Text(label)]),
        TextField(
          obscureText: isObscure,
          decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(vertical: 5)),
        ),
      ],
    );
  }

  // Sélecteur de rôle stylisé
  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['client', 'Chauffeur', 'Admin'].map((role) {
        bool isSelected = selectedRole == role;
        return ChoiceChip(
          label: Text(role),
          selected: isSelected,
          onSelected: (val) => setState(() => selectedRole = role),
          selectedColor: const Color(0xFF3498DB), // Bleu comme sur ta maquette
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }
}

