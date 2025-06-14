import 'package:flutter/material.dart';
import 'package:inventory/models/department.dart';
import 'package:inventory/models/product_issue.dart';
import 'package:inventory/services/department_service.dart';
import 'package:inventory/services/issue_service.dart';

class DepartmentDrawer extends StatefulWidget {
  final Function(Department) onDepartmentSelected;
  final String? selectedDepartmentId;

  const DepartmentDrawer({
    super.key,
    required this.onDepartmentSelected,
    this.selectedDepartmentId,
  });

  @override
  State<DepartmentDrawer> createState() => _DepartmentDrawerState();
}

class _DepartmentDrawerState extends State<DepartmentDrawer> {
  List<Department> departments = [];
  bool isLoading = true;
  String? error;
  Department? selectedDepartment;
  ProductIssue? latestIssue;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await DepartmentService.getAllDepartments();
      if (data != null && data.isNotEmpty) {
        setState(() {
          departments = data;
          selectedDepartment = data.firstWhere(
            (d) => d.id == widget.selectedDepartmentId,
            orElse: () => data.first,
          );
          isLoading = false;
        });

        // Fetch initial issue data
        fetchProductIssueForDepartment(selectedDepartment!.id);
      } else {
        setState(() {
          error = 'No departments available.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductIssueForDepartment(String id) async {
    final result =
        await IssueService.fetchLatestIssueByDepartmentId(departmentId: id);

    if (result is ProductIssue) {
      setState(() {
        latestIssue = result;
      });
    } else {
      setState(() {
        latestIssue = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to fetch data')),
      );
    }
  }

  removeItemFromIssue(String issueId, String productId) async {
    final remove = await IssueService.removeItemFromIssue(issueId, productId);
    print(remove);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Color(0xFF007bff)),
              child: Center(
                child: Text(
                  'Select Department',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(5),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<Department>(
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDepartment,
                  items: departments
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.name),
                          ))
                      .toList(),
                  onChanged: (Department? department) {
                    if (department != null) {
                      setState(() {
                        selectedDepartment = department;
                      });
                      fetchProductIssueForDepartment(department.id);
                      widget.onDepartmentSelected(department);
                    }
                  },
                ),
              ),
            if (latestIssue != null)
              Expanded(
                child: ListView.builder(
                  itemCount: latestIssue!.issueItems.length,
                  itemBuilder: (context, index) {
                    final item = latestIssue!.issueItems[index];
                    final product = item.product;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(product!.name),
                        subtitle: Text(
                          'Quantity: ${product!.quantity} • Price: Rs. ${product.price.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              removeItemFromIssue(latestIssue!.id, product.id);
                              latestIssue!.issueItems.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (latestIssue != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      'Total Products: ${latestIssue!.issueItems.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total Quantity: ${latestIssue!.issueItems.fold<int>(0, (sum, item) => sum + item.product!.quantity)}',
                    ),
                    Text(
                      'Total Price: Rs. ${latestIssue!.issueItems.fold<double>(0, (sum, item) => sum + (item.product!.price * item.product!.quantity)).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
