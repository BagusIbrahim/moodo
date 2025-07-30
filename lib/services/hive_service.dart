// lib/services/hive_service.dart

import 'package:hive/hive.dart';
import '../models/todo.dart';

class HiveService {
  final String _boxName = 'todoBox';

  // Create (Menambah data baru)
  Future<void> addTodo(Todo todo) async {
    var box = await Hive.openBox<Todo>(_boxName);
    await box.add(todo);
  }

  // Read (Hanya membaca semua data yang tersimpan)
  Future<List<Todo>> getTodos() async {
    var box = await Hive.openBox<Todo>(_boxName);
    // Langsung kembalikan daftar tugas dari database tanpa modifikasi.
    return box.values.toList().cast<Todo>();
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