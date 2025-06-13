import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/utils/token_utils.dart';

class ProductService {
  // static const String baseUrl =
  //     'http://yourserver.com'; // Change to your server URL

  static Future<String?> _getToken() async {
    return await TokenUtils.getToken();
  }

  /// Add a new product
  static Future<http.Response> addProduct({
    required String name,
    required String description,
    required int quantity,
    required double price,
    required String categoryId,
    required String userId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/Product');

    final body = jsonEncode({
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'categoryId': categoryId,
      'userId': userId,
    });

    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }

  /// Update existing product
  static Future<http.Response> updateProduct({
    required String id,
    required String name,
    required String description,
    required int quantity,
    required double price,
    required String categoryId,
    required String userId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/Product/$id');

    final body = jsonEncode({
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'categoryId': categoryId,
      'userId': userId,
    });

    return await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }

  /// Get all products
  static Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/Product');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        print('Failed to load products: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }

  /// Get a product by its ID
  static Future<Product?> getProductById(String id) async {
    final url = Uri.parse('$baseUrl/Product/$id');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Product.fromJson(jsonData);
      } else {
        print('Failed to load product: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  /// Delete a product by its ID
  static Future<http.Response> deleteProduct(String id) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/Product/$id');

    return await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
