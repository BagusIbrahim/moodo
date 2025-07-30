import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../services/hive_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Todo? todo;
  const AddTaskScreen({super.key, this.todo});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;
  final List<String> _categoryOptions = [
    'Pekerjaan',
    'Pribadi',
    'Belajar',
    'Belanja',
  ];
  final List<String> _priorityOptions = ['Tinggi', 'Sedang', 'Rendah'];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final HiveService _hiveService = HiveService();
  final NotificationService _notificationService =
      NotificationService();
  bool get isEditing => widget.todo != null;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final todo = widget.todo!;
      _titleController.text = todo.title;
      _detailsController.text = todo.details ?? '';
      _selectedCategory = todo.category;
      _selectedPriority = todo.priority;
      _selectedDate = todo.createdAt;
      _selectedTime = TimeOfDay.fromDateTime(todo.createdAt);
      if (todo.imagePath != null) {
        _imageFile = File(todo.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal terlebih dahulu.'),
          ),
        );
        return;
      }

      String? finalImagePath;
      if (_imageFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_imageFile!.path);
        final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');
        finalImagePath = savedImage.path;
      }

      final finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 0,
        _selectedTime?.minute ?? 0,
      );

      if (isEditing) {
        final updatedTodo = widget.todo!;

        // Batalkan notifikasi lama jika ada sebelum update
        if (updatedTodo.notificationId != null) {
          _notificationService.cancelNotification(updatedTodo.notificationId!);
        }

        updatedTodo.title = _titleController.text;
        updatedTodo.details = _detailsController.text;
        updatedTodo.category = _selectedCategory;
        updatedTodo.priority = _selectedPriority;
        updatedTodo.createdAt = finalDateTime;
        updatedTodo.imagePath = finalImagePath ?? updatedTodo.imagePath;

        // Jadwalkan notifikasi baru
        final int notificationId =
            updatedTodo.notificationId ?? _notificationService.generateUniqueId();
        updatedTodo.notificationId = notificationId;
        final DateTime scheduledForNotification = finalDateTime.subtract(
          const Duration(seconds: 1),
        );

        if (scheduledForNotification.isAfter(DateTime.now())) {
          _notificationService.scheduleNotification(
            id: notificationId,
            title: 'Pengingat Tugas: ${updatedTodo.title}',
            body: updatedTodo.details ?? 'Waktunya menyelesaikan tugasmu!',
            scheduledDate: scheduledForNotification,
            payload: updatedTodo.key.toString(),
          );
        } else {
          print(
            'Tugas berada di masa lalu, notifikasi tidak dijadwalkan ulang.',
          );
          updatedTodo.notificationId = null;
        }

        _hiveService
            .updateTodo(updatedTodo.key, updatedTodo)
            .then((_) => Navigator.pop(context, true));
      } else {
        // Untuk tugas baru
        final newTask = Todo(
          title: _titleController.text,
          details: _detailsController.text,
          category: _selectedCategory,
          priority: _selectedPriority,
          createdAt: finalDateTime,
          imagePath: finalImagePath,
        );

        // Jadwalkan notifikasi untuk tugas baru
        final int notificationId = _notificationService.generateUniqueId();
        newTask.notificationId = notificationId;
        final DateTime scheduledForNotification = finalDateTime.subtract(
          const Duration(seconds: 1),
        );

        if (scheduledForNotification.isAfter(DateTime.now())) {
          _notificationService.scheduleNotification(
            id: notificationId,
            title: 'Pengingat Tugas: ${newTask.title}',
            body: newTask.details ?? 'Waktunya menyelesaikan tugasmu!',
            scheduledDate: scheduledForNotification,
            payload: null, 
          );
        } else {
          print('Tugas berada di masa lalu, notifikasi tidak dijadwalkan.');
          newTask.notificationId = null;
        }

        _hiveService.addTodo(newTask).then((_) => Navigator.pop(context, true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    const primaryColor = Color(0xFF5C6BC0);
    const lightPrimaryColor = Color(0xFF8E99F3);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C2E) : const Color(0xFFF8F8FF),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Tugas' : 'Tugas Baru',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode ? const Color(0xFF2D3250) : primaryColor,
                isDarkMode ? const Color(0xFF474E68) : lightPrimaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Nama Tugas',
                hint: 'Contoh: Selesaikan desain UI',
                icon: Icons.title_rounded,
                isDarkMode: isDarkMode,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Nama tugas tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _detailsController,
                label: 'Detail Tugas',
                hint: 'Contoh: Gunakan warna biru indigo',
                icon: Icons.notes_rounded,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker(
                label: _selectedDate == null
                    ? 'Pilih Tanggal'
                    : DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!),
                onTap: _pickDate,
                icon: Icons.calendar_today_rounded,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker(
                label: _selectedTime == null ? 'Pilih Waktu' : _selectedTime!.format(context),
                onTap: _pickTime,
                icon: Icons.access_time_filled_rounded,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Kategori',
                value: _selectedCategory,
                hint: 'Pilih Kategori',
                items: _categoryOptions,
                onChanged: (value) => setState(() => _selectedCategory = value),
                icon: Icons.category_rounded,
                isDarkMode: isDarkMode,
                validator: (value) => value == null ? 'Kategori harus dipilih' : null,
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Prioritas',
                value: _selectedPriority,
                hint: 'Pilih Prioritas',
                items: _priorityOptions,
                onChanged: (value) => setState(() => _selectedPriority = value),
                icon: Icons.flag_rounded,
                isDarkMode: isDarkMode,
                validator: (value) => value == null ? 'Prioritas harus dipilih' : null,
              ),
              const SizedBox(height: 24),
              Text(
                "Dokumentasi Foto",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Ketuk untuk menambah gambar",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: primaryColor,
                    elevation: 5,
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Tugas',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    String? Function(String?)? validator,
  }) {
    final fillColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(),
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: fillColor,
      ),
      validator: validator,
      style: GoogleFonts.nunito(),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?)? onChanged,
    required IconData icon,
    required bool isDarkMode,
    String? Function(String?)? validator,
  }) {
    final fillColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: GoogleFonts.nunito(color: Colors.grey)),
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.nunito()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required VoidCallback onTap,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.nunito(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}