// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/department.dart';
import 'package:inventory/models/product_issue.dart';
import 'package:inventory/services/department_service.dart';
import 'package:inventory/services/issue_service.dart';

class DepartmentDrawer extends StatefulWidget {
  final Function(Department) onDepartmentSelected;
  final String? selectedDepartmentId;
  final List<Department> departments;

  const DepartmentDrawer({
    super.key,
    required this.onDepartmentSelected,
    this.selectedDepartmentId,
    required this.departments,
  });

  @override
  State<DepartmentDrawer> createState() => _DepartmentDrawerState();
}

class _DepartmentDrawerState extends State<DepartmentDrawer> {
  bool isLoading = true;
  bool isCompleting = false;
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
      if (widget.departments.isNotEmpty) {
        setState(() {
          selectedDepartment = widget.departments.firstWhere(
            (d) => d.id == widget.selectedDepartmentId,
            orElse: () => widget.departments.first,
          );
          isLoading = false;
        });
        await fetchProductIssueForDepartment(selectedDepartment!.id);
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
    try {
      final result = await IssueService.fetchLatestIssueByDepartmentId(
        departmentId: id,
      );
      if (result is ProductIssue) {
        setState(() {
          latestIssue = result;
        });
      } else {
        setState(() {
          latestIssue = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch issue: $e')),
      );
    }
  }

  Future<void> removeItemFromIssue(String issueId, String productId) async {
    try {
      await IssueService.removeItemFromIssue(issueId, productId);
      await fetchProductIssueForDepartment(selectedDepartment!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> makeComplete(String issueId, String departmentId) async {
    setState(() => isCompleting = true);
    try {
      final isCompleted = await IssueService.makeCompleteIssue(issueId);
      if (isCompleted) {
        await fetchProductIssueForDepartment(departmentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Issue completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete issue'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing issue: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  'Department Selection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // Loading/Error state
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else ...[
              // Department selection
              Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<Department>(
                      decoration: const InputDecoration(
                        labelText: 'Select Department',
                        border: InputBorder.none,
                      ),
                      value: selectedDepartment,
                      items: widget.departments
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                      onChanged: (Department? department) async {
                        if (department != null) {
                          setState(() => selectedDepartment = department);
                          await fetchProductIssueForDepartment(department.id);
                          widget.onDepartmentSelected(department);
                        }
                      },
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Issue items list
              if (latestIssue != null && latestIssue!.issueItems.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Items',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Chip(
                              label: Text(
                                '${latestIssue!.issueItems.length} items',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: latestIssue!.issueItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = latestIssue!.issueItems[index];
                            final product = item.product;
                            return Dismissible(
                              key: Key('${product!.id}_$index'),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirm'),
                                    content: const Text(
                                        'Are you sure you want to remove this item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => removeItemFromIssue(
                                latestIssue!.id,
                                product.id,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.quantityIssued}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Rs. ${(product.price * item.quantityIssued).toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => removeItemFromIssue(
                                    latestIssue!.id,
                                    product.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in current issue',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Summary and complete button
              if (latestIssue != null && latestIssue!.issueItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Items:'),
                          Text(
                            latestIssue!.issueItems.length.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Quantity:'),
                          Text(
                            latestIssue!.issueItems
                                .fold<int>(
                                    0, (sum, item) => sum + item.quantityIssued)
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:'),
                          Text(
                            'Rs. ${latestIssue!.issueItems.fold<double>(0, (sum, item) => sum + (item.product!.price * item.quantityIssued)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isCompleting
                              ? null
                              : () => makeComplete(
                                    latestIssue!.id,
                                    latestIssue!.departmentId,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: isCompleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            isCompleting ? 'Processing...' : 'Complete Issue',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
