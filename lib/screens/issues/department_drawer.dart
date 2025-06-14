import 'package:flutter/material.dart';
import 'package:inventory/models/department.dart';
import 'package:inventory/services/department_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
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
                padding: EdgeInsets.all(24),
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
                      widget.onDepartmentSelected(department);
                      // Navigator.pop(context); // Close drawer
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
