import 'package:flutter/material.dart';
import 'package:inventory/services/department_service.dart';

class AddDepartmentPage extends StatefulWidget {
  @override
  _AddDepartmentPageState createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await DepartmentService.addDepartment(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department added successfully')),
        );
        _nameController.clear();
        _descriptionController.clear();
      } else {
        setState(() {
          _errorMessage = 'Failed to add department. Please try again';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while adding department.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Department')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Department Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitDepartment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007bff),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add Product'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
