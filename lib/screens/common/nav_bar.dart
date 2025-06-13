import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:inventory/screens/category/view_category.dart';
import 'package:inventory/utils/token_utils.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _currentIndex = 0;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    bool expired = await TokenUtils.isExpiredToken();
    setState(() {
      isExpired = expired;
    });
  }

  List<IconData> get _iconList => [
        Icons.inventory_2, // Products
        Icons.category, // Categories
        Icons.apartment, // Departments
        isExpired ? Icons.login : Icons.assignment, // Conditional
      ];

  List<String> get _labels => [
        'Products',
        'Categories',
        'Departments',
        isExpired ? 'Login' : 'Issue',
      ];

  List<Widget> get _pages => [
        const Center(child: Text('Products Page')),
        ViewCategory(),
        const Center(child: Text('Departments Page')),
        isExpired
            ? const Center(
                child: Text('Login Page')) // Replace with Login widget
            : const Center(child: Text('Issue Items Page')),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ElevatedButton(
          child: Text("Logout"),
          onPressed: () {
            TokenUtils.clearToken();
          },
        ),
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onPressed: () {
          // You can handle FAB press based on current index or globally
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.deepPurple : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], color: color),
              const SizedBox(height: 4),
              Text(
                _labels[index],
                style: TextStyle(color: color),
              ),
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 16,
        rightCornerRadius: 16,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
