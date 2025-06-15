// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/category.dart';
import 'package:inventory/screens/category/add_category.dart';
import 'package:inventory/screens/category/edit_category.dart';
import 'package:inventory/services/category_services.dart';
import 'package:inventory/utils/token_utils.dart';

class ViewCategory extends StatefulWidget {
  const ViewCategory({super.key});

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  List<Categoires>? categoires; // Full list
  List<Categoires>? filteredProducts; // Filtered list for search
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getAllCate();
  }

  Future<void> getAllCate() async {
    final data = await CategoiresService.getAllCategories();
    if (data != null) {
      setState(() {
        categoires = data;
        filteredProducts = data; // Show all on load
      });
    }
  }

  void _filterCategory(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProducts = categoires;
      } else {
        filteredProducts = categoires
            ?.where((category) =>
                category.name.toLowerCase().contains(query.toLowerCase()) ||
                category.description
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _deleteCategory(String id) async {
    print("Clicked");
    final deleted = await CategoiresService.deleteCategoires(id);
    if (deleted) {
      // Scaffol.of(context).
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Successfully Deleted")));
      setState(() {
        getAllCate();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Some thing went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = categoires == null;
    final isEmpty =
        !isLoading && (filteredProducts == null || filteredProducts!.isEmpty);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
                return const AddCategoryPage();
              }));
            },
            tooltip: "Add New Category",
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF007bff),
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCategory,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterCategory('');
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isEmpty
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
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: RefreshIndicator(
                          onRefresh: () async => _filterCategory(''),
                          child: ListView.builder(
                            itemCount: filteredProducts!.length,
                            itemBuilder: (context, index) {
                              final category = filteredProducts![index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(category.description),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (builder) {
                                                return EditCategoryPage(
                                                    category: category);
                                              }))
                                            },
                                            icon: const Icon(Icons.edit,
                                                size: 16),
                                            label: const Text('Edit'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                              side: const BorderSide(
                                                  color: Colors.blue),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                {_deleteCategory(category.id)},
                                            // onDelete(department.id),
                                            icon: const Icon(Icons.delete,
                                                size: 16),
                                            label: const Text('Delete'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          )
        ],
      ),
    );
  }
}
