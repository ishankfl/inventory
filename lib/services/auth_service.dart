import 'dart:async';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
import 'package:inventory/models/user.dart';
import 'package:inventory/utils/token_utils.dart';

class AuthService {
  /// Logs in a user and saves token
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/Users/Login');
    print("Calling login endpoint...");

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        await TokenUtils.saveToken(responseJson['token']);
        print("Login Success: ${responseJson['token']}");
        return true;
      } else {
        print("Login Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  /// Adds new staff
  Future<Map<String, dynamic>> addStaff({
    required String name,
    required String email,
    required String password,
    required int role,
  }) async {
    print("try continueing");
    final url = Uri.parse('$baseUrl/Users');
    final token = await TokenUtils.getToken();
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'FullName': name,
              'email': email,
              'password': password,
              'role': role.toString(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(response.statusCode);
      print(response.body);
      final resBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        print('Staff added successfully: $resBody');

        return {'success': true, 'message': 'Staff added successfully.'};
      } else {
        print('Failed to add staff: ${resBody['message']}');
        return {
          'success': false,
          'message': resBody['error'] ?? 'Unknown error'
        };
      }
    } catch (e) {
      print('Add staff error: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }

  /// Fetch all staff
  Future<List<User>> fetChStaff() async {
    print("Fetching staff...");
    final url = Uri.parse('$baseUrl/Users');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> resBody = jsonDecode(response.body);
        return resBody.map((json) => User.fromJson(json)).toList();
      } else {
        print("Failed to fetch staff. Code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print('Fetch staff error: $e');
      return [];
    }
  }

  Future<bool> deleteStaff(String id) async {
    print(id);
    final token = await TokenUtils.getToken();
    print(token);

    final response = await http.delete(
      Uri.parse("$baseUrl/Users/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.body);
    print(response.statusCode);
    return response.statusCode == 200;
  }
}
