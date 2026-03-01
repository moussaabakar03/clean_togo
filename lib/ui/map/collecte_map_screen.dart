import 'package:clean_togo/ui/map/foyer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CollecteMapScreen extends StatefulWidget {
  const CollecteMapScreen({super.key});

  @override
  State<CollecteMapScreen> createState() => _CollecteMapScreenState();
}

class _CollecteMapScreenState extends State<CollecteMapScreen> {
  // Position initiale centrée sur Lomé (selon ta maquette)
  static const LatLng _center = LatLng(6.1319, 1.2228);

  // Simulation de données (en attendant Firebase/API)
  final List<Map<String, String>> foyers = [
    {"nom": "Famille Koffi", "quartier": "Adidogomé"},
    {"nom": "Maison Amah", "quartier": "Tokoin"},
    {"nom": "Famille Kesso", "quartier": "Hédzranawoé"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7E44),
        title: const Text("Liste des foyers", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 13.0),
              myLocationEnabled: true,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: foyers.length,
              itemBuilder: (context, index) {
                // On passe l'élément précis à la fonction ci-dessous
                return _buildFoyerCard(foyers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoyerCard(Map<String, String> foyer) { // <--- Ici, on reçoit "foyer"
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Color(0xFF1E7E44)),
        title: Text(
          foyer["nom"]!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(foyer["quartier"]!),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // CORRECT : Utilise "foyer" au lieu de "foyers[index]"
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoyerDetailScreen(foyer: foyer),
            ),
          );
        },
      ),
    );
  }
}