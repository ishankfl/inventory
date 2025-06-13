import 'package:flutter/material.dart';
import 'package:inventory/screens/login/add_staff_screen.dart';
// import 'package:inventory/screens/login/login_screen.dart';
import 'dart:io';

import 'package:inventory/utils/http_overide.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

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
      home: const AddStaffScreen(),
    );
  }
}
