import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/todo.dart';
import '../services/hive_service.dart';
import '../services/theme_service.dart'; // Import ThemeService

class AddTaskScreen extends StatefulWidget {
  final Todo? todo;
  const AddTaskScreen({super.key, this.todo});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // ... (semua state dan fungsi logika awal tetap sama)
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;
  final List<String> _categoryOptions = ['Pekerjaan', 'Pribadi', 'Belajar', 'Belanja'];
  final List<String> _priorityOptions = ['Tinggi', 'Sedang', 'Rendah'];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final HiveService _hiveService = HiveService();
  bool get isEditing => widget.todo != null;

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
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
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

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih tanggal terlebih dahulu.')),
        );
        return;
      }
      final finalDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime?.hour ?? 0, _selectedTime?.minute ?? 0,
      );
      if (isEditing) {
        final updatedTodo = widget.todo!;
        updatedTodo.title = _titleController.text;
        updatedTodo.details = _detailsController.text;
        updatedTodo.category = _selectedCategory;
        updatedTodo.priority = _selectedPriority;
        updatedTodo.createdAt = finalDateTime;
        _hiveService.updateTodo(updatedTodo.key, updatedTodo).then((_) => Navigator.pop(context, true));
      } else {
        final newTask = Todo(
          title: _titleController.text, details: _detailsController.text,
          category: _selectedCategory, priority: _selectedPriority,
          createdAt: finalDateTime,
        );
        _hiveService.addTodo(newTask).then((_) => Navigator.pop(context, true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ## 1. DETEKSI TEMA ##
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    const primaryColor = Color(0xFF5C6BC0);
    const lightPrimaryColor = Color(0xFF8E99F3);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C2E) : const Color(0xFFF8F8FF),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Tugas' : 'Tugas Baru',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white),
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
                isDarkMode: isDarkMode, // Kirim status tema
                validator: (value) => (value == null || value.isEmpty) ? 'Nama tugas tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _detailsController,
                label: 'Detail Tugas',
                hint: 'Contoh: Gunakan warna biru indigo',
                icon: Icons.notes_rounded,
                isDarkMode: isDarkMode, // Kirim status tema
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker(
                label: _selectedDate == null ? 'Pilih Tanggal' : DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!),
                onTap: _pickDate,
                icon: Icons.calendar_today_rounded,
                isDarkMode: isDarkMode, // Kirim status tema
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker(
                label: _selectedTime == null ? 'Pilih Waktu' : _selectedTime!.format(context),
                onTap: _pickTime,
                icon: Icons.access_time_filled_rounded,
                isDarkMode: isDarkMode, // Kirim status tema
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Kategori',
                value: _selectedCategory,
                hint: 'Pilih Kategori',
                items: _categoryOptions,
                onChanged: (value) => setState(() => _selectedCategory = value),
                icon: Icons.category_rounded,
                isDarkMode: isDarkMode, // Kirim status tema
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
                isDarkMode: isDarkMode, // Kirim status tema
                validator: (value) => value == null ? 'Prioritas harus dipilih' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: primaryColor,
                    elevation: 5,
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Tugas',
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget diperbarui untuk menerima status tema
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    String? Function(String?)? validator,
  }) {
    // ## 2. WARNA KONDISIONAL ##
    final fillColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(),
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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