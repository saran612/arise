import 'package:flutter/material.dart';

void main() {
  runApp(const AriseApp());
}

class AriseApp extends StatefulWidget {
  const AriseApp({super.key});

  @override
  State<AriseApp> createState() => _AriseAppState();
}

class _AriseAppState extends State<AriseApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.category,
    required this.priority,
    required this.createdAt,
  });
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
  final List<Todo> _todos = [
    Todo(
      id: '1',
      title: 'Design Arise brand identity',
      isCompleted: true,
      category: 'Design',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Todo(
      id: '2',
      title: 'Implement Flutter state management',
      isCompleted: false,
      category: 'Work',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Todo(
      id: '3',
      title: 'Review PRs and backlog',
      isCompleted: false,
      category: 'Work',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Todo(
      id: '4',
      title: 'Hydrate and stretch for 10 minutes',
      isCompleted: false,
      category: 'Fitness',
      priority: 'Low',
      createdAt: DateTime.now(),
    ),
  ];

  final List<String> _categories = ['All', 'Work', 'Design', 'Fitness', 'Personal'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dialog/modal inputs
  final TextEditingController _todoTitleController = TextEditingController();
  String _newTodoCategory = 'Work';
  String _newTodoPriority = 'Medium';

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
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get _completedCount => _todos.where((t) => t.isCompleted).length;
  double get _completionRate => _todos.isEmpty ? 0.0 : _completedCount / _todos.length;

  void _toggleTodo(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((t) => t.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
  }

  void _addTodo() {
    if (_todoTitleController.text.trim().isEmpty) return;

    setState(() {
      _todos.insert(
        0,
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _todoTitleController.text.trim(),
          category: _newTodoCategory,
          priority: _newTodoPriority,
          createdAt: DateTime.now(),
        ),
      );
    });

    _todoTitleController.clear();
    Navigator.of(context).pop();
  }

  void _editTodo(Todo todo) {
    _todoTitleController.text = todo.title;
    _newTodoCategory = todo.category;
    _newTodoPriority = todo.priority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTodoFormBottomSheet(
        title: 'Edit Task',
        submitLabel: 'Save Changes',
        onSubmit: () {
          if (_todoTitleController.text.trim().isEmpty) return;
          setState(() {
            todo.title = _todoTitleController.text.trim();
            todo.category = _newTodoCategory;
            todo.priority = _newTodoPriority;
          });
          _todoTitleController.clear();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showAddTodoSheet() {
    _todoTitleController.clear();
    _newTodoCategory = 'Work';
    _newTodoPriority = 'Medium';

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
                Text(
                  title,
                  style: theme.textTheme.headlineMedium,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredTodos;
    final isDark = widget.currentThemeMode == ThemeMode.dark;

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
                          'assets/image/1024_black.png',
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
                    const SizedBox(height: 24),

                    // Progress Overview Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.85),
                            theme.colorScheme.primary.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_completedCount of ${_todos.length} tasks completed',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _completionRate,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 6,
                                ),
                              ),
                              Text(
                                '${(_completionRate * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
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
                                            color: todo.isCompleted
                                                ? theme.colorScheme.tertiary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: todo.isCompleted
                                                  ? theme.colorScheme.tertiary
                                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: todo.isCompleted
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
                                                  color: todo.isCompleted
                                                      ? theme.colorScheme.onSurface.withOpacity(0.3)
                                                      : theme.colorScheme.onSurface,
                                                  decoration: todo.isCompleted
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
