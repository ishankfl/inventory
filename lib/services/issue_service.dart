import 'dart:convert';

import 'package:inventory/constants/server.dart';
import 'package:inventory/models/product.dart';
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
              'departmentId': departmentId,
              'issuedById': issuedById,
              'item': {
                'productId': productId,
                'quantityIssued': quantityIssued
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(response.body);
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

  /// Remove a single issued item from a department
  static Future<bool> removeIssuedItemFromDepartment({
    required String departmentId,
    required String productId,
  }) async {
    final token = await TokenUtils.getToken();
    final url = Uri.parse(
        '$baseUrl/Issues/Department/$departmentId/Product/$productId');
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
