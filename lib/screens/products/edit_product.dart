import 'package:flutter/material.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/screens/common/snack_bar.dart';
import 'package:inventory/services/product_services.dart';
import 'package:inventory/utils/token_utils.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    bool isExpired = await TokenUtils.isExpiredToken();
    if (isExpired) {
      setState(() => isSaving = false);
      if (mounted) {
        AppSnackBar.showError(context, "Please Login First with admin account");
      }
      return;
    }

    // Create updated product object
    // final updatedProduct = Product(
    //   id: widget.product.id,
    //   userId: widget.product.userId,
    //   categoryId: widget.product.categoryId,
    //   name: _nameController.text.trim(),
    //   description: _descriptionController.text.trim(),
    //   price: double.tryParse(_priceController.text.trim()) ?? 0,
    //   quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
    //   // Add more fields as needed (e.g., category)
    // );

    try {
      // Call your update service (implement this in ProductService)
      await ProductService.updateProduct(
        id: widget.product.id,
        userId: widget.product.userId,
        categoryId: widget.product.categoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      );

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Product updated successfully!');

        // Navigator.pop(context, updatedProduct); // Pass updated product back
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to update product: $e');
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Product Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      minLines: 2,
                      maxLines: 4,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter description'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final d = double.tryParse(value ?? '');
                        return (d == null || d < 0)
                            ? 'Enter valid price'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final i = int.tryParse(value ?? '');
                        return (i == null || i < 0)
                            ? 'Enter valid quantity'
                            : null;
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveProduct(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007bff),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Product'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
