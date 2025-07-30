import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../services/theme_service.dart';
// import '../services/pdf_service.dart';

class TaskDetailScreen extends StatelessWidget {
  final Todo todo;

  const TaskDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    final Color primaryColor =
        isDarkMode ? const Color(0xFF2D3250) : const Color(0xFF5C6BC0);
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1C1C2E) : const Color(0xFFF8F8FF),
      appBar: AppBar(
        title: Text(
          todo.title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode ? const Color(0xFF2D3250) : primaryColor,
                isDarkMode
                    ? const Color(0xFF474E68)
                    : const Color(0xFF8E99F3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Selesai
            Row(
              children: [
                Icon(
                  todo.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: todo.isCompleted
                      ? Colors.green.shade400
                      : subTextColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  todo.isCompleted ? 'Selesai' : 'Belum Selesai',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: todo.isCompleted
                        ? Colors.green.shade400
                        : subTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Detail Tugas
            _buildDetailRow(
              icon: Icons.notes_rounded,
              label: 'Detail',
              value: todo.details ?? 'Tidak ada detail',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),

            // Tanggal & Waktu
            _buildDetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Waktu Dijadwalkan',
              value: DateFormat('EEEE, d MMMM yyyy HH:mm', 'id_ID')
                  .format(todo.createdAt),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),

            // Kategori
            _buildDetailRow(
              icon: Icons.category_rounded,
              label: 'Kategori',
              value: todo.category ?? 'Tidak Ada',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),

            // Prioritas
            _buildDetailRow(
              icon: Icons.flag_rounded,
              label: 'Prioritas',
              value: todo.priority ?? 'Tidak Ada',
              isDarkMode: isDarkMode,
              valueColor: _getPriorityColor(todo.priority),
            ),
            const SizedBox(height: 16),

            // Gambar (Jika ada)
            if (todo.imagePath != null && File(todo.imagePath!).existsSync())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dokumentasi Foto",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(todo.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: subTextColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk menampilkan baris detail
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    Color? valueColor,
  }) {
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.grey : Colors.grey.shade600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: subTextColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: valueColor ?? textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper untuk mendapatkan warna prioritas
  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'Tinggi':
        return Colors.red.shade400;
      case 'Sedang':
        return Colors.orange.shade400;
      case 'Rendah':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}