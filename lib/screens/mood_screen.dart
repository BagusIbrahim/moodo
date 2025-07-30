import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/todo.dart';
import '../services/hive_service.dart';
import '../services/pdf_service.dart'; // <-- Import service PDF
import '../services/theme_service.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final HiveService _hiveService = HiveService();
  List<Todo> _allTodos = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Map<String, dynamic> _moodData = {};
  
  final Color _primaryColor = const Color(0xFF5C6BC0); 
  final Color _lightPrimaryColor = const Color(0xFF8E99F3);

  @override
  void initState() {
    super.initState();
    _loadDataAndCalculateMood();
  }

  Future<void> _loadDataAndCalculateMood() async {
    _allTodos = await _hiveService.getTodos();
    _calculateMoodForDay(_selectedDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _calculateMoodForDay(selectedDay);
    });
  }

  void _calculateMoodForDay(DateTime day) {
    final tasksForDay = _allTodos.where((task) {
      return isSameDay(task.createdAt, day);
    }).toList();

    if (tasksForDay.isEmpty) {
      _moodData = {
        'mood': 'Hari Santai',
        'icon': Icons.emoji_emotions_rounded,
        'color': Colors.purpleAccent,
        'summary': 'Tidak ada tugas yang dijadwalkan.',
        'completionRate': 1.0, 
      };
    } else {
      final totalTasks = tasksForDay.length;
      final completedTasks =
          tasksForDay.where((task) => task.isCompleted).length;
      final completionRate =
          totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

      if (completionRate >= 0.8) {
        _moodData = {
          'mood': 'Luar Biasa!',
          'icon': Icons.celebration_rounded,
          'color': Colors.green,
          'summary': 'Anda menyelesaikan $completedTasks dari $totalTasks tugas.',
          'completionRate': completionRate,
        };
      } else if (completionRate >= 0.5) {
        _moodData = {
          'mood': 'Produktif',
          'icon': Icons.sentiment_satisfied_rounded,
          'color': Colors.blue,
          'summary': 'Anda menyelesaikan $completedTasks dari $totalTasks tugas.',
          'completionRate': completionRate,
        };
      } else if (completionRate > 0) {
        _moodData = {
          'mood': 'Cukup Baik',
          'icon': Icons.sentiment_neutral_rounded,
          'color': Colors.orange,
          'summary': 'Anda menyelesaikan $completedTasks dari $totalTasks tugas.',
          'completionRate': completionRate,
        };
      } else {
        _moodData = {
          'mood': 'Perlu Ditingkatkan',
          'icon': Icons.sentiment_dissatisfied_rounded,
          'color': Colors.red,
          'summary': 'Terdapat $totalTasks tugas yang belum diselesaikan.',
          'completionRate': completionRate,
        };
      }
    }
    setState(() {});
  }
  
  void _generateReport() async {
    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Panggil metode statis secara langsung dari kelasnya
      await PdfService.generateMonthlyReport(_allTodos, _focusedDay);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat laporan: $e')),
      );
    } finally {
      // Guard the use of context with a mounted check
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C2E) : const Color(0xFFF8F8FF),
      appBar: AppBar(
        title: Text('Laporan Mood Harian', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode ? const Color(0xFF2D3250) : _primaryColor,
                isDarkMode ? const Color(0xFF474E68) : _lightPrimaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Cetak Laporan Bulan Ini',
            onPressed: _generateReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCalendar(isDarkMode),
              const SizedBox(height: 24),
              _buildMoodDisplay(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodDisplay(bool isDarkMode) {
    if (_moodData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3250) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // Perbaikan dari withOpacity(0.1)
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: MoodChartPainter(
                  completionRate: _moodData['completionRate'],
                  moodColor: _moodData['color'],
                ),
                child: Center(
                  child: Icon(
                    _moodData['icon'],
                    size: 60,
                    color: _moodData['color'],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _moodData['mood'],
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _moodData['color'],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _moodData['summary'],
              style: GoogleFonts.nunito(
                fontSize: 17,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3250) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // Perbaikan dari withOpacity(0.08)
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2040, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: _primaryColor.withAlpha(128), // Perbaikan dari withOpacity(0.5)
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: _primaryColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class MoodChartPainter extends CustomPainter {
  final double completionRate;
  final Color moodColor;

  MoodChartPainter({required this.completionRate, required this.moodColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = moodColor.withAlpha(38) // Perbaikan dari withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    Paint progressPaint = Paint()
      ..color = moodColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    double angle = 2 * pi * completionRate;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}