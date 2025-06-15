// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:inventory/constants/server.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/models/product_issue.dart';
import 'package:inventory/utils/token_utils.dart';
import 'package:http/http.dart' as http;

class IssueService {
  static Future<Map<String, dynamic>> addNewItem(
      {required String departmentId,
      required String productId,
      required int quantityIssued}) async {
    final token = await TokenUtils.getToken();
    final issuedById = await TokenUtils.getUserId();
    final url = Uri.parse('$baseUrl/Issues/OneProduct');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'DepartmentId': departmentId,
              'IssuedById': issuedById,
              'productId': productId,
              'quantityIssued': quantityIssued
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Category with this name already exist'
        };
      }
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Category added successfully.'};
      } else {
        return {'success': false, 'message': 'Failed to add Category.'};
      }
    } catch (e) {
      print(e);
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }

  static Future<dynamic> fetchLatestIssueByDepartmentId({
    required String departmentId,
  }) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/Issues/deptId/$departmentId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = ProductIssue.fromJson(jsonDecode(response.body));
        return model;
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Category with this name already exists.'
        };
      } else if (response.statusCode == 204) {
        return null;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch issue. Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }

  /// Issue a product to a department
  static Future<bool> issueProductToDepartment({
    required String departmentId,
    required String productId,
    required int quantity,
  }) async {
    final token = await TokenUtils.getToken();
    final issuedById = await TokenUtils.getUserId();
    final url = Uri.parse('$baseUrl/Issues/OneProduct');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'departmentId': departmentId,
              'issuedById': issuedById,
              'item': {'productId': productId, 'quantityIssued': quantity},
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Get all issued items for a department
  static Future<List<IssuedItem>> getIssuedItemsForDepartment(
      String departmentId) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse(
        '$baseUrl/Issues/Department/$departmentId'); // Adjust endpoint as needed
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.map((e) => IssuedItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<bool> removeItemFromIssue(
      String issueId, String productId) async {
    final token = await TokenUtils.getToken();
    final url =
        Uri.parse('$baseUrl/issues/removeItem/$issueId/Product/$productId');

    try {
      final response = await http.delete(
        url,
        headers: {
          // 'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Item successfully removed');
        return true;
      } else {
        print('Failed to remove item: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  static Future<bool> makeCompleteIssue(String issueId) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/Issues/CompleteIssue/$issueId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response body: ${response.body}');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Issue successfully marked as complete.');
        return true;
      } else {
        print('Failed to complete issue: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error occurred while completing issue: $e');
      return false;
    }
  }

  /// Remove all issued items for a department
  static Future<bool> removeAllIssuedItemsForDepartment({
    required String departmentId,
  }) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/Issues/Department/$departmentId/RemoveAll');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<ProductIssue>> getAllProductIssue() async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse('$baseUrl/Issues');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        return jsonResponse.map((item) => ProductIssue.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load issues: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching issues: $e');
      throw Exception('Failed to load issues');
    }
  }
}

// Model for an issued item (adjust as per your API response)
class IssuedItem {
  final Product product;
  int quantity;

  IssuedItem({required this.product, required this.quantity});

  factory IssuedItem.fromJson(Map<String, dynamic> json) {
    return IssuedItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantityIssued'] ?? json['quantity'] ?? 0,
    );
  }
}
