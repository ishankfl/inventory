import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventory/models/user.dart';
import 'package:inventory/services/auth_service.dart';

class ViewStaffPage extends StatefulWidget {
  const ViewStaffPage({super.key});

  @override
  State<ViewStaffPage> createState() => _ViewStaffPageState();
}

class _ViewStaffPageState extends State<ViewStaffPage> {
  List<User> staffList = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<User> fiteredUser = [];

  @override
  void initState() {
    super.initState();
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    setState(() {
      isLoading = true;
    });
    AuthService service = AuthService();
    final users = await service.fetChStaff();
    setState(() {
      staffList = users;
      isLoading = false;
    });
  }

  Future<void> deleteStaff(String id) async {
    AuthService service = AuthService();
    final success = await service.deleteStaff(id);
    if (success) {
      setState(() {
        staffList.removeWhere((user) => user.id == id);
      });
    }
  }

  void _filterUser(String query) {
    if (query.isEmpty) {
      fetchStaff();
    }
    setState(() {
      searchQuery = query;
      fiteredUser = staffList.where((user) {
        return user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.fullName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      staffList = fiteredUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Staff"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchStaff,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Staff',
            onPressed: () {
              // Navigate to Add Staff page
              // Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Color(0xFF007bff),

            // color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUser,
              decoration: InputDecoration(
                hintText: 'Search Users...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterUser('');
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
            child: RefreshIndicator(
              onRefresh: fetchStaff,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : staffList.isEmpty
                      ? const Center(child: Text("No staff found."))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: staffList.length,
                          itemBuilder: (context, index) {
                            final user = staffList[index];
                            final isAdmin = user.role == 0;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: isAdmin
                                      ? Colors.blue.shade100
                                      : Colors.green.shade100,
                                  child: Icon(
                                    isAdmin ? Icons.security : Icons.person,
                                    color: isAdmin ? Colors.blue : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  user.fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(user.email),
                                    const SizedBox(height: 2),
                                    Text(
                                      isAdmin ? 'Admin' : 'Staff',
                                      style: TextStyle(
                                        color: isAdmin
                                            ? Colors.blue
                                            : Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Confirm Deletion"),
                                        content: Text(
                                            "Are you sure you want to delete ${user.fullName}?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context), // Cancel
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(
                                                  context); // Close dialog
                                              await deleteStaff(
                                                  user.id); // Proceed to delete
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
