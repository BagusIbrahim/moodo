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

  @HiveField(3)
  String? details;

  @HiveField(4)
  String? category;

  @HiveField(5)
  String? priority;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  int? notificationId;


  Todo({
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.details,
    this.category,
    this.priority,
    this.imagePath,
    this.notificationId,
  });
}
