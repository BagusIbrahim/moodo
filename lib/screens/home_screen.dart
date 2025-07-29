import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_task_screen.dart';
import '../models/todo.dart';
import '../services/hive_service.dart';
import '../services/theme_service.dart';
import 'mood_screen.dart';

enum SortMethod { byTime, byPriority }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HiveService _hiveService = HiveService();
  List<Todo> _allTodos = [];
  List<Todo> _filteredTodos = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  SortMethod _currentSortMethod = SortMethod.byTime;

  final Color _primaryColor = const Color(0xFF5C6BC0); // Indigo
  final Color _lightPrimaryColor = const Color(0xFF8E99F3);
  final Color _accentColor = const Color(0xFFFFB74D);  // Oranye lembut

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  int _getPriorityValue(String? priority) {
    switch (priority) {
      case 'Tinggi': return 0;
      case 'Sedang': return 1;
      case 'Rendah': return 2;
      default: return 3;
    }
  }

  Future<void> _loadTodos() async {
    _allTodos = await _hiveService.getTodos();
    _filterTasksByDate(_selectedDay);
  }

  void _filterTasksByDate(DateTime date) {
    List<Todo> tasksForDay = _allTodos.where((task) {
      return isSameDay(task.createdAt, date);
    }).toList();

    if (_currentSortMethod == SortMethod.byTime) {
      tasksForDay.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      tasksForDay.sort((a, b) {
        int priorityCompare = _getPriorityValue(a.priority).compareTo(_getPriorityValue(b.priority));
        if (priorityCompare == 0) {
          return a.createdAt.compareTo(b.createdAt);
        }
        return priorityCompare;
      });
    }
    setState(() => _filteredTodos = tasksForDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _filterTasksByDate(selectedDay);
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDay = pickedDate;
        _focusedDay = pickedDate;
      });
      _filterTasksByDate(pickedDate);
    }
  }

  void _updateTaskStatus(Todo todo) {
    todo.isCompleted = !todo.isCompleted;
    _hiveService.updateTodo(todo.key, todo).then((_) => _loadTodos());
  }

  void _deleteTask(Todo todo) {
    _hiveService.deleteTodo(todo.key).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${todo.title}" telah dihapus.')),
      );
      _loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    return Scaffold(
      drawer: _buildDrawer(themeService),
      backgroundColor: isDarkMode ? const Color(0xFF1C1C2E) : const Color(0xFFF8F8FF),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCalendarSection(isDarkMode),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tugas Anda",
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          "Anda memiliki ${_filteredTodos.length} tugas hari ini",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _currentSortMethod == SortMethod.byTime
                            ? Icons.access_time_filled_rounded
                            : Icons.sort_rounded,
                        color: isDarkMode ? _lightPrimaryColor : _primaryColor,
                      ),
                      tooltip: _currentSortMethod == SortMethod.byTime
                          ? 'Urutkan berdasarkan Prioritas'
                          : 'Urutkan berdasarkan Waktu',
                      onPressed: () {
                        setState(() {
                          _currentSortMethod = _currentSortMethod == SortMethod.byTime
                              ? SortMethod.byPriority
                              : SortMethod.byTime;
                          _filterTasksByDate(_selectedDay);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _filteredTodos.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada tugas untuk hari ini.',
                          style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredTodos.length,
                        itemBuilder: (context, index) {
                          final todo = _filteredTodos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF2D3250) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                left: BorderSide(
                                  color: _getPriorityColor(todo.priority),
                                  width: 5,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Checkbox(
                                value: todo.isCompleted,
                                onChanged: (value) => _updateTaskStatus(todo),
                                activeColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              title: Text(
                                todo.title,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                "${todo.category ?? 'Lainnya'} • ${DateFormat('HH:mm').format(todo.createdAt)}",
                                style: GoogleFonts.nunito(color: Colors.grey),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_rounded, color: Colors.grey.shade500),
                                    onPressed: () async {
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddTaskScreen(todo: todo),
                                        ),
                                      );
                                      if (result == true) _loadTodos();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_rounded, color: Colors.red.shade300),
                                    onPressed: () => _deleteTask(todo),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 10,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (result == true) _loadTodos();
        },
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 6.0,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 20.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home_rounded, color: _primaryColor, size: 30),
                onPressed: () {},
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.bar_chart_rounded, color: isDarkMode ? Colors.white70 : Colors.grey.shade600, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MoodScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'Tinggi': return Colors.red.shade400;
      case 'Sedang': return Colors.orange.shade400;
      case 'Rendah': return Colors.green.shade400;
      default: return Colors.grey.shade400;
    }
  }

  Widget _buildDrawer(ThemeService themeService) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryColor, _lightPrimaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Text('Pengaturan', style: GoogleFonts.nunito(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          ),
          Consumer<ThemeService>(
            builder: (context, theme, child) {
              return ListTile(
                leading: Icon(theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                title: Text('Mode Gelap', style: GoogleFonts.nunito()),
                trailing: Switch(
                  value: theme.isDarkMode,
                  onChanged: (value) {
                    theme.toggleTheme();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ## FUNGSI YANG DIPERBARUI ##
  Widget _buildCalendarSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkMode ? const Color(0xFF2D3250) : _primaryColor,
            isDarkMode ? const Color(0xFF474E68) : _lightPrimaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // LOGO APLIKASI
          Text(
            'Moodo',
            style: GoogleFonts.pacifico(
              color: Colors.white,
              fontSize: 28,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          // Kalender
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2040, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, date) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _calendarFormat = _calendarFormat == CalendarFormat.week
                          ? CalendarFormat.month
                          : CalendarFormat.week;
                    });
                  },
                  onLongPress: () => _showDatePicker(),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                          onPressed: () {
                            setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day));
                          },
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat.yMMMM().format(date),
                              style: GoogleFonts.nunito(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              _calendarFormat == CalendarFormat.week ? Icons.arrow_drop_down_rounded : Icons.arrow_drop_up_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                          onPressed: () {
                            setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, _focusedDay.day));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.nunito(color: Colors.white.withOpacity(0.8)),
              weekendStyle: GoogleFonts.nunito(color: Colors.white.withOpacity(0.8)),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: GoogleFonts.nunito(color: Colors.white),
              weekendTextStyle: GoogleFonts.nunito(color: Colors.white),
              outsideTextStyle: GoogleFonts.nunito(color: Colors.white.withOpacity(0.5)),
              todayDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: GoogleFonts.nunito(color: _primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}