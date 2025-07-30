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

  // Read (Membaca semua data, dan menghasilkan tugas berulang)
  Future<List<Todo>> getTodos() async {
    var box = await Hive.openBox<Todo>(_boxName);
    final List<Todo> allStoredTodos = box.values.toList().cast<Todo>();
    final List<Todo> generatedTodos = [];

    final DateTime now = DateTime.now(); // Mengambil waktu sekarang

    for (var todo in allStoredTodos) {
      generatedTodos.add(todo); // Tambahkan instance asli tugas

      // Jika ini adalah tugas berulang dan belum selesai
      // (Kita hanya menghasilkan instance berulang dari tugas yang belum selesai dan berulang)
      if (todo.repeatFrequency != 'Tidak Berulang' &&
          todo.isCompleted == false) {
        DateTime currentOccurrenceDate = DateTime(
          todo.createdAt.year,
          todo.createdAt.month,
          todo.createdAt.day,
          todo.createdAt.hour,
          todo.createdAt.minute,
        );

        // Loop untuk menghasilkan instance tugas berulang di masa depan
        // Kita bisa atur batasnya, misalnya hingga 1 tahun ke depan
        // Atau hingga repeatEndDate jika ditentukan
        while (currentOccurrenceDate.isBefore(
          now.add(const Duration(days: 365)),
        )) {
          // Hanya tambahkan jika tanggalnya di masa depan atau hari ini
          // dan tidak melampaui repeatEndDate jika ada
          if (currentOccurrenceDate.isAfter(now) ||
              isSameDay(currentOccurrenceDate, now)) {
            if (todo.repeatEndDate == null ||
                currentOccurrenceDate.isBefore(
                  todo.repeatEndDate!.add(const Duration(days: 1)),
                )) {
              generatedTodos.add(
                Todo(
                  title: todo.title,
                  details: todo.details,
                  category: todo.category,
                  priority: todo.priority,
                  createdAt: currentOccurrenceDate,
                  isCompleted:
                      false, // Instance berulang selalu dimulai sebagai belum selesai
                  imagePath: todo.imagePath,
                  repeatFrequency:
                      todo.repeatFrequency, // Copy frekuensi pengulangan
                  repeatEndDate:
                      todo.repeatEndDate, // Copy tanggal berakhir pengulangan
                  // notificationId tidak perlu di-copy, setiap instance akan memiliki notifikasi baru jika diperlukan
                ),
              );
            }
          }

          // Maju ke kejadian berikutnya berdasarkan frekuensi
          if (todo.repeatFrequency == 'Harian') {
            currentOccurrenceDate = currentOccurrenceDate.add(
              const Duration(days: 1),
            );
          } else if (todo.repeatFrequency == 'Mingguan') {
            currentOccurrenceDate = currentOccurrenceDate.add(
              const Duration(days: 7),
            );
          } else if (todo.repeatFrequency == 'Bulanan') {
            // Logika untuk maju bulanan dengan hati-hati agar tidak ada masalah tanggal (misal 31 Jan ke Feb)
            int nextMonth = currentOccurrenceDate.month + 1;
            int nextYear = currentOccurrenceDate.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            DateTime candidateDate = DateTime(
              nextYear,
              nextMonth,
              todo.createdAt.day, // Coba pertahankan hari asli
              todo.createdAt.hour,
              todo.createdAt.minute,
            );
            // Jika hari asli tidak ada di bulan berikutnya (misal 31 Feb), sesuaikan ke hari terakhir bulan itu
            if (candidateDate.month != nextMonth) {
              candidateDate = DateTime(
                nextYear,
                nextMonth + 1,
                0, // Hari 0 dari bulan berikutnya adalah hari terakhir bulan saat ini
                todo.createdAt.hour,
                todo.createdAt.minute,
              );
            }
            currentOccurrenceDate = candidateDate;
          } else {
            break; // Jika frekuensi tidak dikenal atau 'Tidak Berulang', hentikan loop
          }
        }
      }
    }

    // Mengurutkan semua tugas (asli dan yang digenerate) dari yang terbaru
    generatedTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return generatedTodos;
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

  // Helper untuk membandingkan tanggal (perlu di sini karena digunakan di getTodos)
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
