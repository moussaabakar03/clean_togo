import 'package:clean_togo/ui/auth/login_screen.dart';
import 'package:clean_togo/ui/history/history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // État pour savoir si la tournée a commencé
  bool _isTourneeLancee = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7E44),
        title: const Text("Tournée du jour", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E7E44)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF1E7E44))),
                  SizedBox(height: 10),
                  Text("Chauffeur Pro", style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text("Lomé, Togo", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Tournée du jour"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Mon Historique"),
              onTap: () {
                Navigator.pop(context); // Ferme le menu
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Déconnexion"),
                      content: const Text("Voulez-vous vraiment vous déconnecter ?"),
                      actions: [
                        TextButton(
                          child: const Text("Annuler"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text("Oui, quitter", style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                                    (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Carte grise : Résumé des foyers
            _buildSummaryCard(),

            const SizedBox(height: 20),

            // 2. Zone de suivi (Conditionnelle)
            if (_isTourneeLancee)
              _buildTrackingCard()
            else
              _buildEmptyState(),

            const SizedBox(height: 40),

            // 3. Bouton principal en bas
            if (!_isTourneeLancee) _buildStartButton(),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, color: Colors.black54),
          SizedBox(width: 10),
          Text(
            "Foyers à visiter : 12",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 10),
        Text(
          "Aucune tournée en cours.\nAppuyez sur démarrer pour commencer.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              "Suivi du Camion de Collecte",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          // Placeholder Map
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.map_rounded, size: 60, color: Colors.blueGrey),
          ),
          // Infos
          _infoRow("Position Actuelle:", "Tokoin Wuiti"),
          _infoRow("Heures de Passage:", "08:15 - 09:00"),
          _infoRow("Points Collectés:", "12 Ramassages"),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                // Action pour marquer la collecte (iPhone 17-11)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E7E44),
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text("Marquer Collecte", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 14)),
          const Divider(height: 10),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E7E44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          setState(() {
            _isTourneeLancee = true;
          });
        },
        child: const Text(
          "Démarrer une tournée",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}