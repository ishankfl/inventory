import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:inventory/main.dart';
import 'package:inventory/screens/category/view_category.dart';
import 'package:inventory/screens/department/view_departments.dart';
import 'package:inventory/screens/issues/create_product_issue.dart';
import 'package:inventory/screens/login/login_screen.dart';
import 'package:inventory/screens/products/view_products.dart';
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
        ViewProducts(),
        const ViewCategory(),
        const ViewAllDepartments(),
        isExpired ? const LoginScreen() : const CreateProductIssue(),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Ishan Kafle'),
              accountEmail: const Text('ishan@example.com'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: theme.colorScheme.onSurface),
              title: Text('Profile',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
              title: Text('Settings',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {},
            ),
            SwitchListTile(
              title: Text('Dark Theme',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              secondary:
                  Icon(Icons.dark_mode, color: theme.colorScheme.onSurface),
              value: themeNotifier.value == ThemeMode.dark,
              onChanged: (bool value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            // Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.onSurface),
              title: Text('Logout',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                TokenUtils.clearToken();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF007bff),
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onPressed: () {
          // Handle FAB press
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        // borderColor: Colors.red,
        // splashColor: Colors.green,
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 199, 230, 243);
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], color: color),
              const SizedBox(height: 4),
              Text(_labels[index], style: TextStyle(color: color)),
            ],
          );
        },
        backgroundColor: isDarkMode ? theme.cardColor : theme.primaryColor,
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
