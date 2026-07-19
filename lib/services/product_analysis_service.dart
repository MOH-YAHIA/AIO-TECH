import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/product_analysis_model.dart';
import 'auth_services.dart';

class ProductAnalysisService {
  static const String baseUrl =
      'https://aiotech-api-f6fcc8gxcjhudffq.austriaeast-01.azurewebsites.net/api/productanalysis';

  final _authService = AuthService();

  Future<Map<String, dynamic>> getMyProducts() async {
    try {
      final headers = await _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/my-products'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];

        // 2. FIXED: Correctly extract the list of products whether the backend
        // wraps it in a 'data' map or sends a direct List.
        if (decoded is Map) {
          if (decoded.containsKey('data')) {
            rawList = decoded['data'] as List<dynamic>;
          } else if (decoded.containsKey('\$values')) {
            // .NET sometimes wraps lists in $values to preserve object references
            rawList = decoded['\$values'] as List<dynamic>;
          }
        } else if (decoded is List) {
          rawList = decoded;
        }

        // Map the extracted JSON list to our Dart model
        final products = rawList
            .map((item) => ProductAnalysisModel.fromJson(item))
            .toList();

        return {'success': true, 'data': products};
      }

      if (response.statusCode == 401) {
        return {'success': false, 'message': 'Session expired, please login again'};
      }

      return {'success': false, 'message': 'Failed to load products'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }
}