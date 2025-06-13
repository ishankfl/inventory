// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/category.dart';
import 'package:inventory/screens/category/add_category.dart';
import 'package:inventory/services/category_services.dart';
import 'package:inventory/utils/token_utils.dart';

class ViewCategory extends StatefulWidget {
  const ViewCategory({super.key});

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  List<Categoires>? categoires = [];

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
      });
    } // print(categories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              icon: Icon(
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
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        // title: const Text(" "),
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
      body: categoires == null || categoires!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: categoires!.map((category) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Navigate to edit screen
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text("Edit"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Call delete function
                                  },
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text("Delete"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
