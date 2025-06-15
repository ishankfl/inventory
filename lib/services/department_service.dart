// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory/constants/server.dart';
import 'package:inventory/models/department.dart';

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
    try {
      final response = await http.delete(Uri.parse('$baseUrl/Department"/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting department: $e');
      return false;
    }
  }

  static Future<bool> addDepartment(String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Department"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': description}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding department: $e');
      return false;
    }
  }

  static Future<bool> updateDepartment(
      int id, String name, String description) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Department"/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': description}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating department: $e');
      return false;
    }
  }
}
