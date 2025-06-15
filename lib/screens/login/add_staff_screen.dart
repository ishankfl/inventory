// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventory/screens/users/view_staff_page.dart';
import 'dart:convert';

import 'package:inventory/services/auth_service.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;
  String error = '';

  Future<void> _handleSubmit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        selectedRole == null) {
      setState(() {
        error = 'All fields are required';
      });
      return;
    }

    setState(() {
      error = '';
    });

    try {
      final response = await AuthService().addStaff(
        name: name,
        email: email,
        password: password,
        role: int.parse(selectedRole!), // assuming dropdown gives string
      );

      if (response['success']) {
        // Show success message
        Navigator.push(context, MaterialPageRoute(builder: (builder) {
          return const ViewStaffPage();
        }));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff added successfully!')),
        );

        // Clear form
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        setState(() => selectedRole = null);
      } else {
        setState(() {
          error = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        error = 'An unexpected error occurred. Please try again later.';
      });
      print('Submit error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        title: const Text('Add New Staff'),
        // backgroundColor: Colors.deepPurple[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              if (error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red[200],
                  child:
                      Text(error, style: const TextStyle(color: Colors.black)),
                ),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person),
              const SizedBox(height: 15),
              _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email),
              const SizedBox(height: 15),
              _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                dropdownColor: Color.fromARGB(
                    255, 241, 246, 252), // dropdown list background
                value: selectedRole,
                style:
                    TextStyle(color: Color(0xFF007bff)), // selected value color
                onChanged: (value) => setState(() => selectedRole = value),
                decoration: _inputDecoration('Select Role'),
                items: const [
                  DropdownMenuItem(
                    value: '0',
                    child: Text(
                      'Admin',
                      style: TextStyle(
                          color: Color(0xFF007bff)), // match selected style
                    ),
                  ),
                  DropdownMenuItem(
                    value: '1',
                    child: Text(
                      'Staff',
                      style: TextStyle(
                          color: Color(0xFF007bff)), // match selected style
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Add Staff'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      // labelStyle: const TextStyle(color: Colors.white),
      // enabledBorder: OutlineInputBorder(
      //   borderSide: const BorderSide(color: Colors.white),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      // focusedBorder: OutlineInputBorder(
      //   borderSide: const BorderSide(color: Colors.white),
      //   borderRadius: BorderRadius.circular(10),
      // ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscureText = false}) {
    return TextField(
        controller: controller,
        obscureText: obscureText,
        // style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
        )
        //   labelStyle: const TextStyle(color: Colors.white),
        //   prefixIcon: Icon(icon, color: Colors.white),
        //   enabledBorder: OutlineInputBorder(
        //     borderSide: const BorderSide(color: Colors.white),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   focusedBorder: OutlineInputBorder(
        //     borderSide: const BorderSide(color: Colors.white),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        // ),
        );
  }
}
