import 'package:hive/hive.dart';
import '../models/todo.dart';

class HiveService {
  final String _boxName = 'todoBox';

  // Create (Menambah data baru)
  Future<void> addTodo(Todo todo) async {
    var box = await Hive.openBox<Todo>(_boxName);
    await box.add(todo);
  }

  // Read (Membaca semua data)
  Future<List<Todo>> getTodos() async {
    var box = await Hive.openBox<Todo>(_boxName);
    // Mengurutkan dari yang terbaru
    final todos = box.values.toList().cast<Todo>();
    todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return todos;
  }

  // Update (Memperbarui data)
  Future<void> updateTodo(dynamic key, Todo todo) async {
    var box = await Hive.openBox<Todo>(_boxName);
    await box.put(key, todo);
  }

  // Delete (Menghapus data)
  Future<void> deleteTodo(dynamic key) async {
    var box = await Hive.openBox<Todo>(_boxName);
    await box.delete(key);
  }
}