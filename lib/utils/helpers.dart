import 'package:url_launcher/url_launcher.dart';

class MapHelper {
  // Fonction pour ouvrir l'adresse dans l'application GPS du téléphone
  static Future<void> ouvrirGps(String adresse) async {
    // On encode l'adresse pour qu'elle soit lisible dans une URL (remplace les espaces par %20 etc.)
    final String query = Uri.encodeComponent(adresse);
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible de lancer la carte pour : $adresse';
      }
    } catch (e) {
      print("Erreur GPS : $e");
    }
  }
}