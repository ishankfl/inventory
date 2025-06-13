// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/services/category_services.dart';
import 'package:inventory/utils/token_utils.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await TokenUtils.getUserId(); // Make sure this returns `int`

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await CategoiresService.addCategoires(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      userId: userId!,
    );

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      _nameController.clear();
      _descriptionController.clear();
    } else {
      setState(() {
        _errorMessage = response['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007bff),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add Category'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
