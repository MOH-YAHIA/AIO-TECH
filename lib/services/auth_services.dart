import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://aiotech-api-f6fcc8gxcjhudffq.austriaeast-01.azurewebsites.net/api/auth';

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'age': age,
          'gender': gender,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveSession(data);
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      // FIX: expose the real error during development
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveSession(data);
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', data['token'] ?? '');
    await prefs.setString('full_name', data['fullName'] ?? '');
    await prefs.setString('email', data['email'] ?? '');
    await prefs.setInt('age', (data['age'] as int?) ?? 0);
    await prefs.setString('gender', data['gender'] ?? '');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  // Fetch all user profile data from SharedPreferences
  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString('full_name') ?? 'Guest',
      'email': prefs.getString('email') ?? 'No email provided',
      'age': prefs.getInt('age') ?? 0,
      'gender': prefs.getString('gender') ?? 'Not specified',
    };
  }

  // Update session data locally (You can later connect this to an API)
  Future<void> updateProfileLocal({
    required String fullName,
    required String email,
    int? age,
    String? gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('full_name', fullName);
    await prefs.setString('email', email);
    if (age != null) await prefs.setInt('age', age);
    if (gender != null) await prefs.setString('gender', gender);
  }
}