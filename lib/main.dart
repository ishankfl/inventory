import 'package:flutter/material.dart';
import 'package:inventory/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMS Login',
      theme: ThemeData(
        primaryColor: const Color(0xFF007bff),
        scaffoldBackgroundColor: const Color(0xFF007bff),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007bff)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
