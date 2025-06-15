// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/department.dart';
import 'package:inventory/screens/department/add_department.dart';
import 'package:inventory/screens/department/edit_department.dart';
import 'package:inventory/services/department_service.dart';
import 'package:inventory/utils/token_utils.dart';

class ViewAllDepartments extends StatefulWidget {
  const ViewAllDepartments({Key? key}) : super(key: key);

  @override
  State<ViewAllDepartments> createState() => _ViewAllDepartmentsState();
}

class _ViewAllDepartmentsState extends State<ViewAllDepartments>
    with TickerProviderStateMixin {
  List<Department>? departments;
  List<Department>? filteredDepartments;
  bool isLoading = true;
  String? error;
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
    fetchDepartments();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDepartments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await DepartmentService.getAllDepartments();
      if (data == null) {
        setState(() {
          error = 'Failed to fetch departments.';
          isLoading = false;
        });
      } else {
        setState(() {
          departments = data;
          filteredDepartments = data;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _filterDepartments(String query) {
    setState(() {
      searchQuery = query;
      filteredDepartments = departments?.where((department) {
        return department.name.toLowerCase().contains(query.toLowerCase()) ||
            department.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void onDelete(String id) async {
    bool isExpired = await TokenUtils.isExpiredToken();
    if (isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Login First with admin account")),
      );
      return;
    }
    final department = departments?.firstWhere((d) => d.id == id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Department',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${department?.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      bool success = await DepartmentService.deleteDepartment(id);

      // Hide loading indicator
      Navigator.pop(context);

      if (success) {
        setState(() {
          departments = departments?.where((d) => d.id != id).toList();
          filteredDepartments =
              filteredDepartments?.where((d) => d.id != id).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${department?.name} deleted successfully'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo functionality if needed
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete department'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void onEdit(Department department) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Edit ${department.name} - Not implemented yet')),
    // );
    Navigator.push(context, MaterialPageRoute(builder: (builder) {
      return EditDepartmentPage(department: department);
    }));
  }

  void onAdd() async {
    bool isExpired = await TokenUtils.isExpiredToken();
    if (isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Login First with admin account")),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (builder) {
      return AddDepartmentPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50],
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
          "Departments",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        // title: const Text(
        //   '',
        //   style: TextStyle(fontWeight: FontWeight.w600),
        // ),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black87,
        elevation: 0,
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(1),
        //   child: Container(
        //     height: 1,
        //     color: Colors.grey[200],
        //   ),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDepartments,
            tooltip: "Refresh",
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
            tooltip: 'Add Department',
          ),
          const SizedBox(width: 8),
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
              onChanged: _filterDepartments,
              decoration: InputDecoration(
                hintText: 'Search departments...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterDepartments('');
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

          // Department List
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading departments...'),
                      ],
                    ),
                  )
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: fetchDepartments,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredDepartments == null ||
                            filteredDepartments!.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  searchQuery.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.corporate_fare_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'No departments found for "$searchQuery"'
                                      : 'No departments available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (searchQuery.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: onAdd,
                                    icon: const Icon(Icons.add),
                                    label:
                                        const Text('Add your first department'),
                                  ),
                                ]
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchDepartments,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: filteredDepartments!.length,
                              itemBuilder: (context, index) {
                                final department = filteredDepartments![index];
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
                                        child: _buildDepartmentCard(department),
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

  Widget _buildDepartmentCard(Department department) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to department details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.corporate_fare,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          department.name,
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
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              if (department.description.isNotEmpty) ...[
                Text(
                  department.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onEdit(department),
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
                    onPressed: () => onDelete(department.id),
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
}
