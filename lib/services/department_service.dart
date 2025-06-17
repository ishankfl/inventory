// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
import 'package:inventory/models/department.dart';
import 'package:inventory/utils/token_utils.dart';

class DepartmentService {
  static Future<List<Department>?> getAllDepartments() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/Department"));
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Department.fromJson(json)).toList();
      } else {
        print('Failed to load departments: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching departments: $e');
      return null;
    }
  }

  static Future<bool> deleteDepartment(String id) async {
    final token = await TokenUtils.getToken();
    try {
      final response = await http.delete(Uri.parse('$baseUrl/Department"/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          });
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting department: $e');
      return false;
    }
  }

  static Future<bool> addDepartment(String name, String description) async {
    final token = await TokenUtils.getToken();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Department"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'name': name, 'description': description}),
      ); 
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding department: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> updateDepartment(Department dept) async {
    final token = await TokenUtils.getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Department/${dept.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'name': dept.name,
          'description': dept.description,
        }),
      );

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': "You are not authorized to perform this action." ??
              'Failed to update Category.'
        };
      }

      if (response.statusCode == 200) {
        return {'success': true};
      } else if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? 'Bad request'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Department not found'};
      } else {
        return {'success': false, 'message': 'Unexpected error'};
      }
    } catch (e) {
      print('Error updating department: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
