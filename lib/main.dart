// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/todo.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  // Pastikan binding Flutter siap sebelum menjalankan async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());

  runApp(
    // Bungkus aplikasi dengan ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan tema dari ThemeService
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Moodo',
      themeMode: themeService.themeMode,
      
      // Tema untuk Mode Terang (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.white,
          elevation: 8,
        ),
        cardTheme: CardThemeData( // <-- PERBAIKAN DI SINI
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF00A3A3),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF00A3A3), width: 2),
          ),
        ),
      ),

      // Tema untuk Mode Gelap (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Color(0xFF1F1F1F),
        ),
        cardTheme: CardThemeData( // <-- PERBAIKAN DI SINI
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.tealAccent,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.tealAccent, width: 2),
          ),
        ),
      ),

      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}