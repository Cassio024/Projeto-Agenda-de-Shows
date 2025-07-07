// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Mude para o endereço do seu servidor. Se estiver a testar localmente,
  // use 'http://10.0.2.2:5000' para o emulador Android ou o IP da sua máquina.
  static const String _baseUrl = 'https://agenda-backend-api-4es1.onrender.com/api';

  // --- Funções de Utilizador ---

  static Future<Map<String, dynamic>> registerUser(String name, String email, String password, DateTime birthDate) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'birthDate': birthDate.toIso8601String(),
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no login');
    }
  }

  // --- Funções de Eventos ---

  static Future<List<dynamic>> getEvents(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/events/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  static Future<Map<String, dynamic>> createEvent(String userId, String eventName, String venue, DateTime dateTime) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'eventName': eventName,
        'venue': venue,
        'dateTime': dateTime.toIso8601String(),
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao criar evento');
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/events/$eventId'));
    if (response.statusCode != 200) {
      throw Exception('Falha ao apagar evento');
    }
  }
  static Future<Map<String, dynamic>> verifyIdentity(String email, DateTime birthDate) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/users/verify-identity'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'birthDate': birthDate.toIso8601String(),
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Falha na verificação');
  }
}

static Future<void> resetPassword(String userId, String newPassword) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/users/reset-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'newPassword': newPassword,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao redefinir a senha');
  }
}

}

