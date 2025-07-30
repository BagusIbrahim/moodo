// lib/models/todo.dart

import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1) // Pastikan typeId ini unik di antara semua model Hive
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String? details;

  @HiveField(4)
  String? category;

  @HiveField(5)
  String? priority;

  @HiveField(6)
  String? imagePath; // Untuk menyimpan path gambar (sudah ada di kodemu)

  @HiveField(7) // <<-- Field untuk ID Notifikasi
  int? notificationId;

  @HiveField(8) // <<-- Field untuk frekuensi pengulangan
  String? repeatFrequency; // Contoh: 'None', 'Daily', 'Weekly', 'Monthly'

  @HiveField(9) // <<-- Field untuk tanggal akhir pengulangan (opsional)
  DateTime? repeatEndDate;

  Todo({
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.details,
    this.category,
    this.priority,
    this.imagePath,
    this.notificationId,
    this.repeatFrequency,
    this.repeatEndDate,
  });
}
