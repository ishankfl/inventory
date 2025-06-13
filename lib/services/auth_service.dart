import 'dart:async';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
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

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
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
          'message': resBody['message'] ?? 'Unknown error'
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
}
