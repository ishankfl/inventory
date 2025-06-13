import 'package:flutter/material.dart';
import 'package:inventory/screens/common/nav_bar.dart';
import 'package:inventory/screens/login/add_staff_screen.dart';
// import 'package:inventory/screens/login/login_screen.dart';
import 'dart:io';

import 'package:inventory/utils/http_overide.dart';
import 'package:inventory/utils/token_utils.dart';

void main() async {
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
        appBarTheme: const AppBarTheme(color: Color(0xFF007bff)),
        primaryColor: (Colors.white),
        scaffoldBackgroundColor: const Color.fromARGB(255, 180, 209, 233),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007bff)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const CustomNavigationBar(),
    );
  }
}
