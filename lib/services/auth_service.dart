import 'dart:async';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
import 'package:inventory/utils/token_utils.dart';

class AuthService {
  // final String url = baseUrl; // Replace with your actual API

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/Users/Login');
    print("called");

    try {
      print('Calling:   -> $baseUrl/Users/Login');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        await TokenUtils.saveToken(responseJson['token']);
        // Optionally save token using SharedPreferences here
        print("Login Success: ${responseJson['token']}");
        return true;
      } else {
        print("Login Failed: ${response.body}");
        return false;
      }
    }
    // catch TimeoutException as e {

    // }
    catch (e) {
      print("Error logging in: $e");
      return false;
    }
  }
}
