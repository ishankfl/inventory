import 'package:flutter/material.dart';
import 'package:inventory/models/category.dart';
import 'package:inventory/models/user.dart';
import 'package:inventory/screens/category/view_category.dart';
import 'package:inventory/screens/common/nav_bar.dart';
import 'package:inventory/services/category_services.dart';

class EditCategoryPage extends StatefulWidget {
  final Categoires category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descController = TextEditingController(text: widget.category.description);
  }

  Future<Map<String, dynamic>> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedCategory = Categoires(
        user: User.empty(),
        id: widget.category.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        userId: '',
      );

      final response =
          await CategoiresService.updateCategoires(updatedCategory);

      setState(() {
        _isLoading = false;
      });

      if (!mounted)
        return {"success": false, "message": "Context no longer valid"};

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? "Updated successfully")),
        );
        Navigator.push(context, MaterialPageRoute(builder: (builder) {
          return CustomNavigationBar();
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Failed to update")),
        );
      }

      return response;
    }

    return {"success": false, "message": "Validation failed"};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter description'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateCategory,
                  icon: const Icon(Icons.save),
                  label: Text(_isLoading ? "Updating..." : "Update Category"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
