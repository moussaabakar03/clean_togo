import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Ajoute intl: ^0.19.0 dans ton pubspec.yaml pour les dates

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7E44),
        title: const Text("Historique", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // On récupère uniquement les collectes terminées
        stream: FirebaseFirestore.instance
            .collection('foyers')
            .where('statut', isEqualTo: 'termine')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun historique disponible."));
          }

          var foyersTermines = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00838F),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                  ),
                  child: const Text(
                    "Historique des passages effectués",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                // Tableau dynamique
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DataTable(
                    columnSpacing: 10,
                    horizontalMargin: 10,
                    headingRowHeight: 40,
                    columns: const [
                      DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Quartier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: foyersTermines.map((doc) {
                      return DataRow(cells: [
                        DataCell(Text(doc['nom'] ?? "N/A", style: const TextStyle(fontSize: 11))),
                        DataCell(Text(doc['secteur'] ?? "N/A", style: const TextStyle(fontSize: 11))),
                        DataCell(const Text("Terminé", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}