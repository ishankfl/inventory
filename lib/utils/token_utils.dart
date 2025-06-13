/// TOken utils.dart

// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenUtils {
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    print("Token saved successfully");
    print(getToken());
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<bool> isExpiredToken() async {
    final token = await getToken();
    if (token != null) {
      bool isExpired = JwtDecoder.isExpired(token.toString());
      return isExpired;
    }
    return true;
  }

  static Future<String> getUserId() async {
    final token = await getToken();
    print(token);
    final decoded = JwtDecoder.decode(token.toString());
    print(decoded);
    return decoded['id'];
  }
}
