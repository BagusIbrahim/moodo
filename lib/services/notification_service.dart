// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart'
    as tzdata; // Import ini untuk inisialisasi zona waktu
import 'dart:math'; // Import ini untuk menghasilkan ID notifikasi acak

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Constructor
  NotificationService() {
    // Inisialisasi data zona waktu. Penting untuk menjadwalkan notifikasi dengan benar.
    // Ini dipanggil di main.dart juga, tapi di sini aman untuk memastikan
    tzdata.initializeTimeZones();
  }

  // Fungsi untuk menjadwalkan notifikasi
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload, // Data tambahan yang bisa dikirim saat notifikasi diklik
  }) async {
    // Debug print untuk melacak penjadwalan
    print(
      'Mencoba menjadwalkan notifikasi: $title pada $scheduledDate (ID: $id)',
    );

    // Pastikan scheduledDate ada di masa depan. Notifikasi tidak bisa dijadwalkan di masa lalu.
    if (scheduledDate.isBefore(DateTime.now())) {
      print(
        'Tanggal notifikasi sudah lewat. Notifikasi tidak dijadwalkan. ($scheduledDate)',
      );
      return;
    }

    // Ubah DateTime biasa menjadi TZDateTime (timezone-aware DateTime)
    // Ini penting agar notifikasi muncul sesuai zona waktu lokal pengguna.
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      scheduledDate,
      tz.local, // Menggunakan zona waktu lokal perangkat
    );

    // Detail Notifikasi untuk Android
    const AndroidNotificationDetails
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'moodo_task_channel', // ID unik untuk channel notifikasi. Bisa ganti jika mau.
      'Pengingat Tugas Moodo', // Nama channel yang akan terlihat di pengaturan notifikasi Android
      channelDescription:
          'Channel ini digunakan untuk pengingat tugas yang Anda buat.', // Deskripsi channel
      importance: Importance
          .max, // Notifikasi akan muncul sebagai pop-up (head-up notification)
      priority: Priority.high, // Prioritas tinggi
      icon:
          '@mipmap/ic_launcher', // Icon aplikasi yang akan muncul di notifikasi
      ticker: 'Pengingat dari Moodo!', // Teks singkat yang muncul di status bar
      showWhen: true, // Menampilkan waktu saat notifikasi dijadwalkan
      fullScreenIntent:
          true, // Untuk notifikasi penting yang muncul di atas semua aplikasi
    );

    // Detail Notifikasi untuk iOS
    const DarwinNotificationDetails
    iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      // Tambahan pengaturan iOS jika diperlukan, seperti sound, presentAlert, presentBadge, presentSound
    );

    // Gabungan Detail Notifikasi
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Jadwalkan notifikasi
    await notificationsPlugin.zonedSchedule(
      id, // ID unik notifikasi
      title,
      body,
      scheduledTime, // Waktu terjadwal dalam TZDateTime
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // Pastikan notifikasi muncul tepat waktu bahkan saat idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // Interpretasi waktu mutlak
      matchDateTimeComponents: DateTimeComponents
          .dateAndTime, // Untuk notifikasi berulang jika perlu (tapi di sini untuk tunggal)
      payload: payload, // Data yang akan dikirim saat notifikasi diklik
    );
    print(
      'Notifikasi BERHASIL dijadwalkan: "$title" pada $scheduledTime (ID: $id)',
    );
  }

  // Fungsi untuk membatalkan notifikasi berdasarkan ID-nya
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
    print('Notifikasi dengan ID $id dibatalkan.');
  }

  // Fungsi untuk membatalkan semua notifikasi yang tertunda
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    print('Semua notifikasi yang tertunda dibatalkan.');
  }

  // Metode pembantu untuk menghasilkan ID unik untuk setiap notifikasi
  // Menggunakan Random untuk menghasilkan integer unik
  int generateUniqueId() {
    return Random().nextInt(
      2147483647,
    ); // Menggunakan max int value untuk memastikan ID positif
  }
}
