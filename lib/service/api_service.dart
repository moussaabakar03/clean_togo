import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8080/api";


  // --- 1. REQUÊTES PUBLIQUES (Pas de token nécessaire) ---
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Erreur inscription: ${response.body}");
  }

  // --- 2. REQUÊTES SÉCURISÉES (Nécessite le token JWT) ---
  static Future<http.Response> getRequest(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Passage du JWT ici
      },
    );
    return response;
  }

  // Exemple pour un POST sécurisé (ex: enregistrer un foyer)
  static Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response;
  }
}