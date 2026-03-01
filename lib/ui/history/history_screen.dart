import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Titre bleu de la section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF00838F), // Bleu canard de la maquette
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: const Text(
                "Historique des anciens passages\ndu camion de collecte",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            // Tableau des données
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DataTable(
                columnSpacing: 15,
                horizontalMargin: 10,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Heure', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Quartier', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  _buildDataRow("12/04/2024", "08:15", "Tokoin Wuiti", "Terminé"),
                  _buildDataRow("10/04/2024", "09:30", "Agoè Assiyéyé", "Terminé"),
                  _buildDataRow("08/04/2024", "07:50", "Bè Kpota", "Terminé"),
                  _buildDataRow("06/04/2024", "11:20", "Adidogomé", "Terminé"),
                  _buildDataRow("04/04/2024", "10:10", "Nyekonakpoé", "Terminé"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bouton de détails
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E7E44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {
                  // Action pour voir plus de détails
                },
                child: const Text("Voir les détails", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String date, String heure, String quartier, String status) {
    return DataRow(cells: [
      DataCell(Text(date, style: const TextStyle(fontSize: 12))),
      DataCell(Text(heure, style: const TextStyle(fontSize: 12))),
      DataCell(Text(quartier, style: const TextStyle(fontSize: 12))),
      DataCell(
          Text(status,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)
          )
      ),
    ]);
  }
}