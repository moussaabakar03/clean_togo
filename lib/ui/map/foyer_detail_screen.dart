import 'package:clean_togo/core/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FoyerDetailScreen extends StatefulWidget {
  final Map<String, String> foyer;

  const FoyerDetailScreen({super.key, required this.foyer});

  @override
  State<FoyerDetailScreen> createState() => _FoyerDetailScreenState();
}

class _FoyerDetailScreenState extends State<FoyerDetailScreen> {
  final TextEditingController _remarqueController = TextEditingController();
  bool _isCollected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7E44),
        title: Text(widget.foyer["nom"]!, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Carte d'informations du foyer
            _buildInfoCard(),
            const SizedBox(height: 25),

            // 2. Zone de Remarques
            const Text("Ajouter une remarque (optionnel)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _remarqueController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Ex: Poubelle trop lourde, accès difficile...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 30),

            // 3. Bouton de Validation Géant
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: _isCollected ? null : () => _validerPassage(),
                icon: Icon(_isCollected ? Icons.check_circle : Icons.local_shipping, color: Colors.white),
                label: Text(
                  _isCollected ? "COLLECTÉ" : "MARQUER COMME COLLECTÉ",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCollected ? Colors.grey : const Color(0xFF1E7E44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          _infoTile(Icons.person, "Propriétaire", widget.foyer["nom"]!),
          _infoTile(Icons.location_on, "Quartier", widget.foyer["quartier"]!),
          _infoTile(Icons.phone, "Téléphone", "+228 90 12 34 56"),
          _infoTile(Icons.access_time, "Heure prévue", "08:30"),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E7E44), size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  // Dans lib/ui/map/foyer_detail_screen.dart
  void _validerPassage() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      // 1. Récupérer la position GPS (vu à l'étape précédente)
      Position position = await LocationService.determinePosition();

      // 2. Créer l'objet de données
      Map<String, dynamic> collecteData = {
        "foyer_id": widget.foyer["id"], // Assure-toi d'avoir un ID dans ton Map
        "foyer_nom": widget.foyer["nom"],
        "chauffeur_id": user?.uid,
        "date": FieldValue.serverTimestamp(), // Heure exacte du serveur
        "position": GeoPoint(position.latitude, position.longitude),
        "remarque": _remarqueController.text,
        "statut": "Collecté"
      };

      // 3. Envoyer à Firestore dans une collection "historique_collectes"
      await FirebaseFirestore.instance
          .collection('historique_collectes')
          .add(collecteData);

      setState(() {
        _isCollected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Données synchronisées avec succès !")),
      );
    } catch (e) {
      print("Erreur Firebase: $e");
    }
  }
}