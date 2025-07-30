// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import Notifikasi
import 'package:timezone/data/latest.dart'
    as tzdata; // Import untuk data timezone
import 'package:timezone/timezone.dart' as tz; // Import untuk timezone

import 'models/todo.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

// Instance global dari FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Fungsi top-level untuk menangani tap notifikasi di background/terminated state
@pragma(
  'vm:entry-point',
) // Penting untuk Android agar bisa diakses di background
void _notificationTapBackground(NotificationResponse notificationResponse) {
  // Logika di sini akan berjalan bahkan jika aplikasi ditutup sepenuhnya
  // Kamu bisa memproses payload di sini, misalnya membuka database untuk mencari data task
  debugPrint(
    'Notifikasi di background/terminated diklik. Payload: ${notificationResponse.payload}',
  );
  // TODO: Jika kamu ingin navigasi ke layar tertentu dari background,
  // ini akan lebih kompleks dan melibatkan navigasi non-contextual.
}

Future<void> main() async {
  // Pastikan binding Flutter siap sebelum menjalankan async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data zona waktu (sangat penting untuk notifikasi terjadwal)
  tzdata.initializeTimeZones(); // Harus dipanggil sekali di awal aplikasi

  // Konfigurasi Notifikasi untuk Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ); // Icon aplikasi kamu

  // Konfigurasi Notifikasi untuk iOS/macOS
  final DarwinInitializationSettings
  initializationSettingsDarwin = DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Ini dipanggil saat notifikasi diterima saat aplikasi di foreground di iOS/macOS
      debugPrint('Notifikasi foreground iOS/macOS diterima: $title - $body');
      // Kamu bisa menampilkan dialog atau SnackBar di sini jika mau
    },
  );

  // Gabungkan pengaturan untuk semua platform
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin, // Jika kamu mendukung macOS
  );

  // Inisialisasi plugin notifikasi
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // onDidReceiveNotificationResponse dipanggil saat pengguna menekan notifikasi
    // dari foreground, background, atau terminated state (jika aplikasi dibuka dari notifikasi)
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      debugPrint(
        'Notifikasi diklik (foreground/background). Payload: ${notificationResponse.payload}',
      );
      // TODO: Tambahkan logika navigasi di sini jika kamu ingin mengarahkan pengguna ke layar tertentu
      // Misalnya, jika payload adalah ID tugas, kamu bisa membuka layar detail tugas itu.
      // Context UI mungkin tidak langsung tersedia di sini jika aplikasi dimulai dari cold start.
    },
    // Fungsi yang dipanggil saat notifikasi diklik dari background/terminated state
    onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
  );

  // <<-- TAMBAHAN KRITIS: Meminta izin notifikasi dan exact alarms di main() -->>
  // Ini adalah upaya untuk memastikan izin diminta sedini mungkin
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation != null) {
    // Minta izin notifikasi umum (POST_NOTIFICATIONS untuk Android 13+)
    final bool? grantedNotifications = await androidImplementation
        .requestNotificationsPermission();
    print(
      'Status Izin Notifikasi Umum (Android): $grantedNotifications',
    ); // Log penting!

    // Minta izin untuk penjadwalan alarm yang tepat (SCHEDULE_EXACT_ALARM untuk Android 12+)
    final bool? grantedExactAlarm = await androidImplementation
        .requestExactAlarmsPermission();
    print(
      'Status Izin Exact Alarm (Android): $grantedExactAlarm',
    ); // Log penting!

    if (grantedNotifications == false || grantedExactAlarm == false) {
      // Ini hanya log. UI pop-up akan muncul secara otomatis oleh sistem Android.
      // Jika izin ditolak, kita perlu memberi tahu pengguna di UI bahwa notifikasi mungkin tidak berfungsi.
      print(
        'PERINGATAN: Izin notifikasi atau exact alarm tidak diberikan. Notifikasi mungkin tidak berfungsi.',
      );
    }
  }
  // <<-- AKHIR TAMBAHAN KRITIS

  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter()); // Memastikan TodoAdapter terdaftar

  runApp(
    // Bungkus aplikasi dengan ChangeNotifierProvider untuk ThemeService
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
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF1F1F1F)),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
