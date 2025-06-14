// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/screens/issues/department_drawer.dart';
import 'package:inventory/services/product_services.dart';
import 'package:inventory/utils/token_utils.dart';

class CreateProductIssue extends StatefulWidget {
  const CreateProductIssue({super.key});

  @override
  State<CreateProductIssue> createState() => _CreateProductIssueState();
}

class _CreateProductIssueState extends State<CreateProductIssue> {
  List<Product> products = [];
  Map<String, TextEditingController> qtyControllers = {};
  Map<String, bool?> isAvailable = {};
  Map<String, bool> isChecking = {};
  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? departmentId;
  String? departmentName; // Optionally show selected department name

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    for (var controller in qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await ProductService.getAllProducts();
      setState(() {
        products = data;
        isLoading = false;
        qtyControllers.clear();
        isAvailable.clear();
        isChecking.clear();
        for (var product in products) {
          qtyControllers[product.id] = TextEditingController();
          isAvailable[product.id] = null;
          isChecking[product.id] = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  Future<void> _checkQuantityAndSubmit(Product product) async {
    if (departmentId == null || departmentId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose Department First')),
      );
      _scaffoldKey.currentState?.openDrawer();
      return;
    }
    final qtyStr = qtyControllers[product.id]?.text ?? "";
    int requested = int.tryParse(qtyStr.trim()) ?? 0;

    setState(() {
      isChecking[product.id] = true;
      isAvailable[product.id] = null;
    });

    await Future.delayed(
        const Duration(milliseconds: 700)); // Simulate API call

    final available = requested > 0 && requested <= product.quantity;

    setState(() {
      isAvailable[product.id] = available;
      isChecking[product.id] = false;
    });

    if (available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Issue created. $requested/${product.quantity} issued for ${product.name}!')),
      );
      qtyControllers[product.id]?.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Requested quantity not available for ${product.name}! (Stock: ${product.quantity})')),
      );
    }
  }

  String _sortType = '';
  bool _isAscending = true;

  void _sortProducts(String type) {
    setState(() {
      if (_sortType == type) {
        _isAscending = !_isAscending;
      } else {
        _sortType = type;
        _isAscending = true;
      }

      products.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (type) {
          case 'name':
            aValue = a.name.toLowerCase();
            bValue = b.name.toLowerCase();
            break;
          case 'quantity':
            aValue = a.quantity;
            bValue = b.quantity;
            break;
          case 'description':
            aValue = a.description.toLowerCase();
            bValue = b.description.toLowerCase();
            break;
          case 'availability':
            aValue = a.quantity > 0 ? 1 : 0;
            bValue = b.quantity > 0 ? 1 : 0;
            break;
          case 'category':
            aValue = a.category.name.toLowerCase();
            bValue = b.category.name.toLowerCase();
            break;
        }

        int result = aValue.compareTo(bValue);
        return _isAscending ? result : -result;
      });
    });
  }

  Widget _buildSortButton(String label, String type) {
    final isActive = _sortType == type;

    return OutlinedButton.icon(
      onPressed: () => _sortProducts(type),
      icon: Icon(
        isActive
            ? (_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.unfold_more,
        size: 16,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? Colors.white : Colors.blue,
        backgroundColor: isActive ? Colors.blue : null,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const EndDrawerButton(),
      drawer: DepartmentDrawer(
        onDepartmentSelected: (department) {
          setState(() {
            departmentId = department.id;
            departmentName = department.name;
          });
          Navigator.pop(context); // close drawer on selection
        },
        selectedDepartmentId: departmentId,
      ),
      appBar: AppBar(
        title: Text(
          departmentName == null
              ? "Create New Issue"
              : "Issue for $departmentName",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchProducts,
            tooltip: "Refresh",
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              bool isExpired = await TokenUtils.isExpiredToken();
              if (isExpired) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please Login First with admin account")),
                );
                return;
              }
              // Add new product logic if needed
            },
            tooltip: "Add New Product",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products available in cart.'))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortButton('Name', 'name'),
                        _buildSortButton('Qty', 'quantity'),
                        _buildSortButton('Desc', 'description'),
                        _buildSortButton('Type', 'category'),
                        OutlinedButton.icon(
                          onPressed: () {
                            fetchProducts(); // reset
                            setState(() {
                              _sortType = '';
                            });
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (departmentName != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Selected Department: $departmentName',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text(product.description,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[700])),
                                  const SizedBox(height: 8),
                                  Text('Available: ${product.quantity}',
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: TextFormField(
                                          controller:
                                              qtyControllers[product.id],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Enter Qty',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed:
                                            isChecking[product.id] == true
                                                ? null
                                                : () => _checkQuantityAndSubmit(
                                                    product),
                                        child: isChecking[product.id] == true
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : const Text('Add'),
                                      ),
                                    ],
                                  ),
                                  if (isAvailable[product.id] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        isAvailable[product.id] == true
                                            ? 'Quantity available. Issue can be created.'
                                            : 'Requested quantity not available!',
                                        style: TextStyle(
                                          color: isAvailable[product.id] == true
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ]),
    );
  }
}
