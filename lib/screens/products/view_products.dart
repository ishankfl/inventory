// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/screens/products/add_products.dart';
import 'package:inventory/screens/products/edit_product.dart';
import 'package:inventory/services/product_services.dart';
import 'package:inventory/utils/token_utils.dart';

class ViewProducts extends StatefulWidget {
  ViewProducts({super.key});

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts>
    with TickerProviderStateMixin {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = '';
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ProductService.getAllProducts();
      setState(() {
        products = data;
        filteredProducts = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Product product) async {
    bool isExpired = await TokenUtils.isExpiredToken();
    if (isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Login First with admin account")),
      );
      return;
    }
    final delete = await ProductService.deleteProduct(product.id);
    if (delete) {
      setState(() {
        products.removeWhere((p) => p.id == product.id);
        filteredProducts.removeWhere((p) => p.id == product.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted successfully'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo functionality
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete this product'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo functionality
            },
          ),
        ),
      );
    }

    ;
  }

  Color _getStockStatusColor(int quantity) {
    if (quantity == 0) return Colors.red;
    if (quantity < 10) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatusText(int quantity) {
    if (quantity == 0) return 'Out of Stock';
    if (quantity < 10) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ), // Default drawer icon
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
        ),
        title: const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
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
              Navigator.push(context, MaterialPageRoute(builder: (builder) {
                return const AddProductPage();
              }));
            },
            tooltip: "Add New Product",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            // color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Products List
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading products...'),
                      ],
                    ),
                  )
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty
                                  ? 'No products found for "$searchQuery"'
                                  : 'No products available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  // TODO: Navigate to Add Product Page
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add your first product'),
                              ),
                            ]
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      (index * 0.1).clamp(0.0, 1.0),
                                      ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                                      curve: Curves.easeOutBack,
                                    ),
                                  )),
                                  child: FadeTransition(
                                    opacity: _animationController,
                                    child: _buildProductCard(product),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to product details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockStatusColor(product.quantity)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStockStatusText(product.quantity),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStockStatusColor(product.quantity),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailChip(
                    icon: Icons.inventory,
                    label: 'Qty: ${product.quantity}',
                    color: Colors.blue,
                  ),
                  _buildDetailChip(
                      icon: Icons.type_specimen,
                      label: 'Category  ' + "${product.category.name}",
                      color: Colors.blue)
                ],
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate
                      //to edit product screen
                      Navigator.push(context,
                          MaterialPageRoute(builder: (builder) {
                        return EditProductPage(product: product);
                      }));
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(product),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
