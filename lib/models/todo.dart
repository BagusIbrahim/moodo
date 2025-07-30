import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3) // Field baru
  String? details;

  @HiveField(4) // Field baru
  String? category;

  @HiveField(5) // Field baru
  String? priority;

  @HiveField(6)
  String? imagePath; // Untuk menyimpan path gambar

  Todo({
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.details,
    this.category,
    this.priority,
    this.imagePath,
  });
}