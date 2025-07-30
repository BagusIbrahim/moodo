import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:intl/date_symbol_data_local.dart';

import 'models/todo.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

// Instance global dari FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Fungsi top-level untuk menangani tap notifikasi di background/terminated state
@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    'Notifikasi di background/terminated diklik. Payload: ${notificationResponse.payload}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data zona waktu
  tzdata.initializeTimeZones();

  // Inisialisasi format tanggal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // --- Konfigurasi Notifikasi ---
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      debugPrint('Notifikasi foreground iOS/macOS diterima: $title - $body');
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      debugPrint(
        'Notifikasi diklik (foreground/background). Payload: ${notificationResponse.payload}',
      );
    },
    onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
  );

  // Meminta izin notifikasi untuk Android
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    await androidImplementation.requestNotificationsPermission();
    await androidImplementation.requestExactAlarmsPermission();
  }
  // --- Akhir Konfigurasi Notifikasi ---

  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todoBox');

  // Inisialisasi dan muat ThemeService
  final themeService = ThemeService();
  await themeService.loadTheme();

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Moodo',
      themeMode: themeService.themeMode,
      // Tema untuk Mode Terang (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8F8FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.white,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: CircleBorder(),
        ),
      ),

      // Tema untuk Mode Gelap (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF1C1C2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D3250),
          elevation: 0,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Color(0xFF2D3250),
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2D3250),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: CircleBorder(),
        ),
      ),

      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}