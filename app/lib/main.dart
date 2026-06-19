import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AriseApp());
}

class AriseApp extends StatefulWidget {
  const AriseApp({super.key});

  @override
  State<AriseApp> createState() => _AriseAppState();
}

class _AriseAppState extends State<AriseApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      } else {
        _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const orangeAccent = Color(0xFFF97316); // High-quality Orange accent

    return MaterialApp(
      title: 'Arise',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      // Light Theme (60% White, 30% Black, 10% Orange)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: orangeAccent,
          onPrimary: Colors.white,
          background: Color(0xFFFFFFFF), // 60% White dominant background
          onBackground: Color(0xFF0F0F11), // 30% Black secondary text/elements
          surface: Color(0xFFF4F4F6), // Light grey for cards
          surfaceVariant: Color(0xFFE5E7EB), // Input field fill
          onSurface: Color(0xFF0F0F11), // Text on surface elements
          tertiary: Color(0xFF10B981), // Green completion accent
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Color(0xFF0F0F11)),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F0F11)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF4F4F6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFF0F0F11).withOpacity(0.06), width: 1),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          dayPeriodColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return orangeAccent;
            }
            return Colors.transparent;
          }),
          dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return const Color(0xFF0F0F11);
          }),
          dayPeriodBorderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      // Dark Theme (90% Black, 30% White, 10% Orange)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: orangeAccent,
          onPrimary: Colors.white,
          background: Color(0xFF09090B), // 90% Black dominant background
          onBackground: Color(0xFFF4F4F6), // White text/elements
          surface: Color(0xFF18181B), // Dark grey for cards
          surfaceVariant: Color(0xFF27272A), // Input field fill
          onSurface: Color(0xFFF4F4F6), // Text on surface elements
          tertiary: Color(0xFF10B981), // Green completion accent
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Color(0xFFF4F4F6)),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF4F4F6)),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF4F4F6)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFA1A1AA)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF18181B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          dayPeriodColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return orangeAccent;
            }
            return Colors.transparent;
          }),
          dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return const Color(0xFFF4F4F6);
          }),
          dayPeriodBorderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      home: TodoScreen(
        currentThemeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class Todo {
  final String id;
  String title;
  bool isCompleted;
  String category;
  String priority; // 'High', 'Medium', 'Low'
  final DateTime createdAt;
  TimeOfDay? dueTime;
  bool isRepeating;
  List<String> completedDates;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.dueTime,
    this.isRepeating = false,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'dueTime': dueTime != null ? {'hour': dueTime!.hour, 'minute': dueTime!.minute} : null,
      'isRepeating': isRepeating,
      'completedDates': completedDates,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    final dueTimeJson = json['dueTime'];
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      category: json['category'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['createdAt']),
      dueTime: dueTimeJson != null
          ? TimeOfDay(hour: dueTimeJson['hour'], minute: dueTimeJson['minute'])
          : null,
      isRepeating: json['isRepeating'] ?? false,
      completedDates: List<String>.from(json['completedDates'] ?? []),
    );
  }
}

class TodoScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final VoidCallback onThemeToggle;

  const TodoScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeToggle,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _todos = [];
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['All', 'Work', 'Design', 'Fitness', 'Personal'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dialog/modal inputs
  final TextEditingController _todoTitleController = TextEditingController();
  String _newTodoCategory = 'Work';
  String _newTodoPriority = 'Medium';
  TimeOfDay? _newTodoTime;
  bool _newTodoRepeating = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      setState(() {
        _todos.clear();
        _todos.addAll(decoded.map((item) => Todo.fromJson(item)).toList());
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', encoded);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _todoTitleController.dispose();
    super.dispose();
  }

  List<Todo> get _filteredTodos {
    return _todos.where((todo) {
      final matchesCategory = _selectedCategory == 'All' || todo.category == _selectedCategory;
      final matchesSearch = todo.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDate = (todo.createdAt.year == _selectedDate.year &&
          todo.createdAt.month == _selectedDate.month &&
          todo.createdAt.day == _selectedDate.day) || todo.isRepeating;
      return matchesCategory && matchesSearch && matchesDate;
    }).toList();
  }

  bool _isTodoCompletedOnDate(Todo todo, DateTime date) {
    if (todo.isRepeating) {
      final dateKey = "${date.year}-${date.month}-${date.day}";
      return todo.completedDates.contains(dateKey);
    } else {
      return todo.isCompleted;
    }
  }

  int get _completedCount => _filteredTodos.where((t) => _isTodoCompletedOnDate(t, _selectedDate)).length;
  double get _completionRate => _filteredTodos.isEmpty ? 0.0 : _completedCount / _filteredTodos.length;

  void _toggleTodo(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((t) => t.id == id);
      if (todoIndex != -1) {
        final todo = _todos[todoIndex];
        if (todo.isRepeating) {
          final dateKey = "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
          if (todo.completedDates.contains(dateKey)) {
            todo.completedDates.remove(dateKey);
          } else {
            todo.completedDates.add(dateKey);
          }
        } else {
          todo.isCompleted = !todo.isCompleted;
        }
      }
    });
    _saveTodos();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
    _saveTodos();
  }

  void _addTodo() {
    if (_todoTitleController.text.trim().isEmpty) return;

    final now = DateTime.now();
    setState(() {
      _todos.insert(
        0,
        Todo(
          id: now.millisecondsSinceEpoch.toString(),
          title: _todoTitleController.text.trim(),
          category: _newTodoCategory,
          priority: _newTodoPriority,
          createdAt: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            now.hour,
            now.minute,
            now.second,
          ),
          dueTime: _newTodoTime,
          isRepeating: _newTodoRepeating,
        ),
      );
    });

    _todoTitleController.clear();
    _newTodoTime = null;
    _newTodoRepeating = false;
    _saveTodos();
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _editTodo(Todo todo) {
    _todoTitleController.text = todo.title;
    _newTodoCategory = todo.category;
    _newTodoPriority = todo.priority;
    _newTodoTime = todo.dueTime;
    _newTodoRepeating = todo.isRepeating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTodoFormBottomSheet(
        title: 'Edit Task',
        submitLabel: 'Save Changes',
        onDelete: () {
          _deleteTodo(todo.id);
          Navigator.of(context).pop();
        },
        onSubmit: () {
          if (_todoTitleController.text.trim().isEmpty) return;
          setState(() {
            todo.title = _todoTitleController.text.trim();
            todo.category = _newTodoCategory;
            todo.priority = _newTodoPriority;
            todo.dueTime = _newTodoTime;
            todo.isRepeating = _newTodoRepeating;
          });
          _todoTitleController.clear();
          _newTodoTime = null;
          _newTodoRepeating = false;
          _saveTodos();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showAddTodoSheet() {
    _todoTitleController.clear();
    _newTodoCategory = 'Work';
    _newTodoPriority = 'Medium';
    _newTodoTime = null;
    _newTodoRepeating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTodoFormBottomSheet(
        title: 'New Task',
        submitLabel: 'Create Task',
        onSubmit: _addTodo,
      ),
    );
  }

  void _showEditCategoryDialog(String category) {
    if (category == 'All') return;

    final TextEditingController categoryController = TextEditingController(text: category);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Edit Category', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Category name',
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          // Delete button
          TextButton(
            onPressed: () {
              setState(() {
                _categories.remove(category);
                // Update todos belonging to deleted category to the next available category
                final defaultCategory = _categories.firstWhere((c) => c != 'All', orElse: () => 'Work');
                for (var todo in _todos) {
                  if (todo.category == category) {
                    todo.category = defaultCategory;
                  }
                }
                if (_selectedCategory == category) {
                  _selectedCategory = 'All';
                }
              });
              _saveTodos();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = categoryController.text.trim();
              if (newName.isNotEmpty && newName != category) {
                setState(() {
                  final index = _categories.indexOf(category);
                  if (index != -1) {
                    _categories[index] = newName;
                  }
                  // Update all todos under this category
                  for (var todo in _todos) {
                    if (todo.category == category) {
                      todo.category = newName;
                    }
                  }
                  if (_selectedCategory == category) {
                    _selectedCategory = newName;
                  }
                });
                _saveTodos();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFEF4444); // Red
      case 'Medium':
        return const Color(0xFFF59E0B); // Orange
      case 'Low':
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Add Category', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Category name',
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              final newCat = categoryController.text.trim();
              if (newCat.isNotEmpty && !_categories.contains(newCat)) {
                setState(() {
                  _categories.add(newCat);
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoFormBottomSheet({
    required String title,
    required String submitLabel,
    required VoidCallback onSubmit,
    VoidCallback? onDelete,
  }) {
    final theme = Theme.of(context);
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium,
                    ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                        tooltip: 'Delete Task',
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _todoTitleController,
                  autofocus: true,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Category', style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.where((c) => c != 'All').map((category) {
                      final isSelected = _newTodoCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide.none,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _newTodoCategory = category;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Priority', style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 10),
                Row(
                  children: ['Low', 'Medium', 'High'].map((priority) {
                    final isSelected = _newTodoPriority == priority;
                    final pColor = _getPriorityColor(priority);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              _newTodoPriority = priority;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? pColor.withOpacity(0.15) : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? pColor : theme.colorScheme.onSurface.withOpacity(0.05),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: isSelected ? pColor : theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('Time', style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _newTodoTime ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setModalState(() {
                              _newTodoTime = pickedTime;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: _newTodoTime != null ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _newTodoTime != null
                                    ? _newTodoTime!.format(context)
                                    : 'Set a due time (optional)',
                                style: TextStyle(
                                  color: _newTodoTime != null
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontWeight: _newTodoTime != null ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_newTodoTime != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            _newTodoTime = null;
                          });
                        },
                        icon: const Icon(Icons.clear_rounded),
                        tooltip: 'Clear time',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.repeat_rounded,
                          color: _newTodoRepeating ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Repeat Daily',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _newTodoRepeating,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setModalState(() {
                          _newTodoRepeating = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    submitLabel,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredTodos;
    final isDark = widget.currentThemeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : widget.currentThemeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/image/arise_logo.png',
                          height: 38,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              'Arise',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                color: theme.colorScheme.onBackground,
                              ),
                            );
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: Theme.of(context).colorScheme.copyWith(
                                          primary: theme.colorScheme.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate;
                                  });
                                }
                              },
                              icon: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.onBackground.withOpacity(0.08),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: widget.onThemeToggle,
                              icon: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Progress Overview Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFF97316), 
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tasks for ${_formatDate(_selectedDate)}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_completedCount of ${_filteredTodos.length} tasks completed',
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _completionRate,
                                    backgroundColor: theme.colorScheme.onBackground.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: _completionRate,
                                  backgroundColor: theme.colorScheme.onBackground.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                  strokeWidth: 6,
                                ),
                              ),
                              Text(
                                '${(_completionRate * 100).toInt()}%',
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search and Filter Header
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(color: theme.colorScheme.onBackground),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: theme.colorScheme.onBackground.withOpacity(0.7)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selector
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _categories.length) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: _showAddCategoryDialog,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.onBackground.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              onLongPress: category == 'All' ? null : () {
                                _showEditCategoryDialog(category);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            filtered.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: theme.colorScheme.onBackground.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'All clean!',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No tasks matched your search.'
                                : 'Enjoy your day or add a new task to start.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final todo = filtered[index];
                          final priorityColor = _getPriorityColor(todo.priority);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: Key(todo.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 28),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) => _deleteTodo(todo.id),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: InkWell(
                                  onTap: () => _toggleTodo(todo.id),
                                  onDoubleTap: () => _editTodo(todo),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Animated Custom Checkbox
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: _isTodoCompletedOnDate(todo, _selectedDate)
                                                ? theme.colorScheme.tertiary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _isTodoCompletedOnDate(todo, _selectedDate)
                                                  ? theme.colorScheme.tertiary
                                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: _isTodoCompletedOnDate(todo, _selectedDate)
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),

                                        // Todo details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                todo.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: _isTodoCompletedOnDate(todo, _selectedDate)
                                                      ? theme.colorScheme.onSurface.withOpacity(0.3)
                                                      : theme.colorScheme.onSurface,
                                                  decoration: _isTodoCompletedOnDate(todo, _selectedDate)
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  // Category label
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: theme.colorScheme.onSurface.withOpacity(0.06),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Text(
                                                      todo.category,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),

                                                  // Priority dot
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: priorityColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    todo.priority,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: priorityColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (todo.dueTime != null) ...[
                                                    const SizedBox(width: 12),
                                                    Icon(
                                                      Icons.access_time_rounded,
                                                      size: 12,
                                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      todo.dueTime!.format(context),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                  if (todo.isRepeating) ...[
                                                    const SizedBox(width: 12),
                                                    Icon(
                                                      Icons.repeat_rounded,
                                                      size: 13,
                                                      color: theme.colorScheme.primary.withOpacity(0.8),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Daily',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: theme.colorScheme.primary.withOpacity(0.8),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Action buttons (edit/delete)
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                            size: 20,
                                          ),
                                          onPressed: () => _editTodo(todo),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoSheet,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
