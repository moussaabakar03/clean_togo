import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Création des contrôleurs pour récupérer les textes
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _quartierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // ... imports existants ...

  // 2. Fonction d'inscription Firebase modifiée
  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Veuillez remplir les champs obligatoires.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nom': _nomController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'quartier': _quartierController.text.trim(),
        'role': 'chauffeur',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --- MODIFICATION ICI ---
      // 1. On déconnecte l'utilisateur tout de suite pour qu'il doive se connecter
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé ! Connectez-vous."), backgroundColor: Colors.green),
        );

        // 2. On retourne vers l'écran de connexion (LoginScreen)
        Navigator.of(context).pop(); // Si tu es venu du Login, pop suffit
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Une erreur est survenue");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC1FFB1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
        child: Column(
          children: [
            const Icon(Icons.recycling, size: 80, color: Color(0xFF006D32)),
            const Text("Créer un compte", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _inputField("Nom complet", Icons.person_outline, "Nom", _nomController),
                  _inputField("Adresse Mail", Icons.email_outlined, "nom@gmail.com", _emailController),
                  _inputField("Téléphone", Icons.phone_outlined, "+228...", _phoneController, keyboardType: TextInputType.phone),
                  _inputField("Quartier", Icons.location_on_outlined, "Adidogomé", _quartierController),
                  _inputField("Mot de passe", Icons.lock_outline, "***", _passwordController, isPassword: true),

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E7E44)),
                      onPressed: _register,
                      child: const Text("S'inscrire", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  // --- AJOUT DU LIEN VERS CONNEXION ---
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Déjà un compte ? ", style: TextStyle(fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(), // Retour au Login
                        child: const Text(
                            "Se connecter",
                            style: TextStyle(color: Color(0xFF1E7E44), fontWeight: FontWeight.bold, fontSize: 13)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// ... reste du code (_inputField) ...
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // Widget TextField amélioré avec Controller
  Widget _inputField(String label, IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}