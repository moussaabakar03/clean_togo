import 'package:clean_togo/ui/auth/login_screen.dart';
import 'package:clean_togo/ui/history/history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // N'oublie pas le flutter pub add url_launcher

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isTourneeLancee = false;
  String _userName = "Chargement...";
  String _userQuartier = "Lomé, Togo";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Récupère les infos du profil (Nom/Quartier)
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.get('nom') ?? "Chauffeur";
          _userQuartier = doc.get('quartier') ?? "Lomé, Togo";
        });
      }
    }
  }

  // Fonction pour ouvrir Google Maps avec une adresse texte
  Future<void> _ouvrirItineraire(String adresse) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(adresse)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7E44),
        title: const Text("Clean Togo", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        // ON CHERCHE LA COURSE DU CHAUFFEUR
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where('chauffeurId', isEqualTo: uid)
            .snapshots(),
          // ... à l'intérieur du StreamBuilder des courses ...
          builder: (context, courseSnapshot) {
            if (!courseSnapshot.hasData) return const CircularProgressIndicator();

            // Liste de toutes les courses (secteurs) assignées
            var toutesLesCourses = courseSnapshot.data!.docs;

            if (toutesLesCourses.isEmpty) return _buildPasDeTache();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // On boucle sur CHAQUE course pour afficher son secteur et ses foyers
                  for (var course in toutesLesCourses)
                    Column(
                      children: [
                        _buildHeaderStats(course['secteur']), // Le compteur pour ce secteur
                        const SizedBox(height: 10),
                        if (_isTourneeLancee)
                          _buildListeFoyers(course['secteur']), // Les foyers de ce secteur
                        const SizedBox(height: 20),
                      ],
                    ),

                  if (!_isTourneeLancee) _buildBoutonAction("Démarrer la tournée", () {
                    setState(() => _isTourneeLancee = true);
                  }),
                ],
              ),
            );
          }
      ),
    );
  }

  // --- BLOCS DE CONSTRUCTION UI ---

  // Affiche le nombre de foyers en attente dans le secteur
  Widget _buildHeaderStats(String secteur) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('foyers')
          .where('secteur', isEqualTo: secteur)
          .where('statut', isEqualTo: 'en_attente')
          .snapshots(),
      builder: (context, snapshot) {
        int nb = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1E7E44)),
              Text(" Secteur $secteur : $nb foyers", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
  Widget _buildListeFoyers(String secteur) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('foyers')
          .where('secteur', isEqualTo: secteur)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("Chargement...");
        var docs = snapshot.data!.docs;

        return Column(
          children: docs.map((foyer) {
            // On vérifie le statut pour changer l'apparence
            bool estTermine = foyer['statut'] == 'termine';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: estTermine ? Colors.green.shade50 : Colors.white,
              child: ListTile(
                leading: Icon(
                  estTermine ? Icons.check_circle : Icons.home,
                  color: estTermine ? Colors.green : const Color(0xFF1E7E44),
                ),
                title: Text(foyer['nom'],
                    style: TextStyle(decoration: estTermine ? TextDecoration.lineThrough : null)),
                subtitle: Text(foyer['adresse']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton GPS
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      onPressed: estTermine ? null : () => _ouvrirItineraire(foyer['adresse']),
                    ),
                    // Bouton Valider
                    if (!estTermine)
                      IconButton(
                        icon: const Icon(Icons.done_all, color: Colors.green),
                        onPressed: () => _validerCollecte(foyer.id),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEcranAttente() {
    return const Column(
      children: [
        SizedBox(height: 40),
        Icon(Icons.local_shipping, size: 100, color: Colors.grey),
        Text("Prêt pour la collecte ?", style: TextStyle(fontSize: 18, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPasDeTache() {
    return const Center(
      child: Text("Aucun secteur ne vous est assigné pour le moment."),
    );
  }

  Widget _buildBoutonAction(String label, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E7E44)),
        onPressed: action,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E7E44)),
            accountName: Text(_userName),
            accountEmail: Text(_userQuartier),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Tournée du jour"),
            onTap: () {
              // Si on est déjà sur le Dashboard, on ferme juste le menu
              // Sinon, on repart à zéro sur le Dashboard
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    (route) => false, // Efface toutes les anciennes pages pour éviter de "s'empiler"
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Mon Historique"),
            onTap: () {
              Navigator.pop(context); // 1. On ferme le Drawer d'abord
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen())
              ); // 2. On ouvre l'écran
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  // Fonction pour marquer le ramassage comme terminé dans Firestore
  Future<void> _validerCollecte(String foyerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('foyers')
          .doc(foyerId)
          .update({'statut': 'termine'}); // On change le statut de 'en_attente' à 'termine'

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Collecte validée avec succès !"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Erreur lors de la validation : $e");
    }
  }
}