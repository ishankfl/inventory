import 'package:flutter/material.dart';
import 'package:inventory/screens/common/nav_bar.dart';
import 'package:inventory/utils/http_overide.dart';
import 'dart:io';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          // title: 'IMS Login',
          themeMode: currentTheme,
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Color(0xFF007bff)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // smaller radius
                  ),
                ),
              ),
            ),

            cardColor: Colors.white,
            // cardTheme: CardTheme(color: Color.fromARGB(255, 255, 228, 130)),
            primaryColor: Color(0xFF007bff),
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF007bff)),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF007bff),
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: const TextStyle(color: Color(0xFF007bff)),
              floatingLabelStyle: const TextStyle(color: Color(0xFF007bff)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF007bff)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF007bff)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          debugShowCheckedModeBanner: false,
          home: const CustomNavigationBar(),
        );
      },
    );
  }
}
