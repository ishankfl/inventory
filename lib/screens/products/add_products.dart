import 'package:flutter/material.dart';

import 'package:inventory/models/category.dart';
import 'package:inventory/services/category_services.dart';
import 'package:inventory/services/product_services.dart';
import 'package:inventory/utils/token_utils.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  String? selectedCategoryId;
  List<Categoires> categories = [];
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    print("User id walal call ");
    final userId = await TokenUtils.getUserId();

    final loaded = await CategoiresService.getAllCategories();
    if (loaded != null) {
      setState(() {
        categories = loaded;
      });
    } else {
      setState(() => error = "Failed to load categories");
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await TokenUtils.getUserId();

    try {
      final response = await ProductService.addProduct(
        name: nameController.text.trim(),
        description: descController.text.trim(),
        quantity: int.parse(quantityController.text),
        price: double.parse(priceController.text),
        categoryId: selectedCategoryId!,
        userId: userId!,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully")),
        );
        _formKey.currentState!.reset();
        setState(() {
          selectedCategoryId = null;
        });
      } else {
        setState(() {
          error = "Failed to add product: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,

            // color: Color(0xFF007bff),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF007bff)),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Color(0xFF007bff)),
                  // prefixIcon: const Icon(, color: Color(0xFF007bff)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Color(0xFF007bff)),
                  // prefixIcon: const Icon(, color: Color(0xFF007bff)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: const TextStyle(color: Color(0xFF007bff)),
                  // prefixIcon: const Icon(, color: Color(0xFF007bff)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: const TextStyle(color: Color(0xFF007bff)),
                  // prefixIcon: const Icon(, color: Color(0xFF007bff)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Color(0xFF007bff)),
                  // prefixIcon: const Icon(, color: Color(0xFF007bff)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007bff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat.id.toString(),
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategoryId = val;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => {},
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
