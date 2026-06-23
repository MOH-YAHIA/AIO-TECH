import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'package:http/http.dart' as http;

class ProductService {
  // Base URL for your FastAPI backend
  static const String baseUrl =
      'https://fastapi-endpoint-c3dwb3b3fxc5cgfn.austriaeast-01.azurewebsites.net/api/v1/products';

  // 1. Unified Dispatch API for Home Screen Search
  Future<Map<String, dynamic>> dispatchSearch({
    required String query,
    required String serviceName, // 'product' or 'detailed'
  }) async {
    try {
      debugPrint("Sending request to FastAPI... (Service: $serviceName)");

      final response = await http.post(
        Uri.parse('$baseUrl/dispatch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query_string': query,
          'service_name': serviceName,
          'limit': 3
        }),
      ).timeout(
        const Duration(seconds: 60), // Set a 60-second maximum wait time
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['detail'] ?? 'Search failed to process. Status: ${response.statusCode}',
      };
    } on TimeoutException {
      // Catch the timeout if the server takes too long
      debugPrint("Error: Connection timed out");
      return {'success': false, 'message': 'The server took too long to respond. It might be waking up, please try again.'};
    } catch (e) {
      debugPrint("Error: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 2. Compare API for the Compare Screen
  Future<Map<String, dynamic>> compareDevices({
    required String productA,
    required String productB,
  }) async {
    try {
      debugPrint("Sending Compare request to FastAPI...");

      final response = await http.post(
        Uri.parse('$baseUrl/compare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_a_query': productA,
          'product_b_query': productB,
        }),
      ).timeout(
        const Duration(seconds: 60), // Set a 60-second maximum wait time
      );

      debugPrint("Response Status: ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['detail'] ?? 'Comparison failed. Status: ${response.statusCode}',
      };
    } on TimeoutException {
      // Catch the timeout if the server takes too long
      debugPrint("Error: Comparison timed out");
      return {'success': false, 'message': 'The comparison took too long. Please try again.'};
    } catch (e) {
      debugPrint("Error: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Recursively searches [json] for a Map that looks like a real product
  /// object (i.e. contains a 'name' key). Handles backend responses that
  /// nest the product under varying numbers of 'payload'/'data' wrappers,
  /// and also handles the case where the value at some level is a List of
  /// products (e.g. 'product' mode returning multiple matches) by taking
  /// the first entry.
  ///
  /// Returns an empty map if nothing matching could be found.
  static Map<String, dynamic> extractProductMap(dynamic json) {
    final found = _findProductMap(json, depth: 0);
    return found ?? <String, dynamic>{};
  }

  static Map<String, dynamic>? _findProductMap(dynamic node, {required int depth}) {
    if (depth > 6) return null; // safety guard against unexpected recursion

    if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      // A real product object has a 'name' (and usually 'current_price_egp').
      if (map.containsKey('name') && map['name'] is String) {
        return map;
      }
      // Otherwise, look inside common wrapper keys first, then any value.
      const preferredKeys = ['payload', 'data', 'result', 'product', 'item'];
      for (final key in preferredKeys) {
        if (map.containsKey(key)) {
          final result = _findProductMap(map[key], depth: depth + 1);
          if (result != null) return result;
        }
      }
      for (final value in map.values) {
        final result = _findProductMap(value, depth: depth + 1);
        if (result != null) return result;
      }
    } else if (node is List && node.isNotEmpty) {
      // Take the first product-shaped entry in the list.
      for (final item in node) {
        final result = _findProductMap(item, depth: depth + 1);
        if (result != null) return result;
      }
    }
    return null;
  }

  /// Recursively searches [json] for a Map containing an 'ai_comparison' key,
  /// returning the FULL map at that level (so both 'products' and
  /// 'ai_comparison' siblings are preserved), regardless of how many
  /// 'payload'/'data' wrappers the backend adds.
  ///
  /// Returns an empty map if nothing matching could be found.
  static Map<String, dynamic> extractCompareMap(dynamic json) {
    final found = _findCompareMap(json, depth: 0);
    return found ?? <String, dynamic>{};
  }

  static Map<String, dynamic>? _findCompareMap(dynamic node, {required int depth}) {
    if (depth > 6) return null;

    if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      if (map.containsKey('ai_comparison')) {
        return map;
      }
      const preferredKeys = ['payload', 'data', 'result'];
      for (final key in preferredKeys) {
        if (map.containsKey(key)) {
          final result = _findCompareMap(map[key], depth: depth + 1);
          if (result != null) return result;
        }
      }
      for (final value in map.values) {
        final result = _findCompareMap(value, depth: depth + 1);
        if (result != null) return result;
      }
    } else if (node is List && node.isNotEmpty) {
      for (final item in node) {
        final result = _findCompareMap(item, depth: depth + 1);
        if (result != null) return result;
      }
    }
    return null;
  }
}