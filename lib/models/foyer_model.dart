class Foyer {
  final String id;
  final String nom;
  final String adresse;
  final String telephone;
  bool isCollecte;

  Foyer({required this.id, required this.nom, required this.adresse, required this.telephone, this.isCollecte = false});
}