import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Vérifie les permissions et récupère la position actuelle
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Vérifier si le service GPS est activé sur le téléphone
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Le GPS est désactivé.');
    }

    // 2. Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissions GPS refusées.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Les permissions sont définitivement bloquées.');
    }

    // 3. Récupérer la position avec une haute précision
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
  }
}