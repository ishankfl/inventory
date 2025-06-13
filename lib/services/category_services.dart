import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
import 'package:inventory/models/categoy.dart';
import 'package:inventory/utils/token_utils.dart';
import 'package:inventory/models/categoy.dart';

class CategoiresService {
  /// Adds a new Categoires
  static Future<Map<String, dynamic>> addCategoires({
    required String name,
    required String description,
    required int userId,
  }) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/api/Categoires');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': name,
              'description': description,
              'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final resBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Categoires added successfully.'};
      } else {
        return {
          'success': false,
          'message': resBody['message'] ?? 'Failed to add Categoires.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }

  /// Gets all categories
  static Future<List<Categoires>?> getAllCategories() async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/Category');
    print('$baseUrl/api/Categoires');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final categories = parseCategories(response.body);
        print(categories);
        return categories;
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get categories error: $e');
      return null;
    }
  }

  /// Parses list of categories from JSON
  static List<Categoires> parseCategories(String responseBody) {
    final List<dynamic> parsed = jsonDecode(responseBody);
    return parsed.map<Categoires>((json) => Categoires.fromJson(json)).toList();
  }

  /// Deletes a Categoires by ID
  static Future<bool> deleteCategoires(int id) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/api/Categoires/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete Categoires error: $e');
      return false;
    }
  }

  /// Gets a Categoires by ID
  static Future<Map<String, dynamic>?> getCategoiresById(int id) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/api/Categoires/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get Categoires by ID error: $e');
      return null;
    }
  }

  /// Updates a Categoires by ID
  static Future<Map<String, dynamic>> updateCategoires({
    required int id,
    required String name,
    required String description,
  }) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/api/Categoires/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );

      final resBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Categoires updated successfully.'};
      } else {
        return {
          'success': false,
          'message': resBody['message'] ?? 'Failed to update Categoires.'
        };
      }
    } catch (e) {
      print('Update Categoires error: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }
}
