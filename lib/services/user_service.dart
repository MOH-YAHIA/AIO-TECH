import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';

class UserService {
  // FIX: Was pointing to a placeholder ngrok URL. Now uses the real Azure base URL.
  // The UserController route is api/[controller] → api/user
  static const String baseUrl =
      'https://aiotech-api-f6fcc8gxcjhudffq.austriaeast-01.azurewebsites.net/api/user';

  final _authService = AuthService();

  // ─── Get profile from server ──────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to load profile'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }

  // ─── Update name, email, age, gender ──────────────────────
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    int? age,
    String? gender,
  }) async {
    try {
      // FIX: getAuthHeaders() already includes 'Content-Type: application/json'.
      // Previously the PUT body was sent without Content-Type, so .NET received
      // an empty UpdateProfileDto and silently changed nothing.
      final headers = await _authService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: jsonEncode({
          if (fullName != null) 'fullName': fullName,
          if (email    != null) 'email':    email,
          if (age      != null) 'age':      age,
          if (gender   != null) 'gender':   gender,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Mirror the confirmed server values into local SharedPreferences
        // so the profile screen shows accurate data even without re-fetching.
        await _authService.updateLocalProfile(
          fullName: data['fullName'] ?? fullName ?? '',
          email:    data['email']    ?? email    ?? '',
          age:      data['age']      as int?,
          gender:   data['gender']   as String?,
        );
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Update failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }

  // ─── Change password ───────────────────────────────────────
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // FIX: Same as above — Content-Type was missing, .NET got an empty DTO
      // and BCrypt.Verify would always fail or throw.
      final headers = await _authService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword':     newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }
}