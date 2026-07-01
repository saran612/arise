import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart'; // To access the Todo model

class UserDashboardScreen extends StatefulWidget {
  final List<Todo> todos;

  const UserDashboardScreen({super.key, required this.todos});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String _userName = 'Productivity Champion';
  String _avatarInitials = 'ME';
  int _selectedGradientIndex = 0;
  String? _profileImagePath;

  bool _isEditingName = false;
  late TextEditingController _nameController;

  String _graphCategory = 'All';
  String _graphTimeframe = 'Week';

  // Premium gradient presets for avatar backgrounds
  final List<List<Color>> _gradientPresets = [
    [const Color(0xFFF97316), const Color(0xFFEC4899)], // Orange -> Pink
    [const Color(0xFF2563EB), const Color(0xFF0D9488)], // Blue -> Teal
    [const Color(0xFF7C3AED), const Color(0xFFC084FC)], // Purple -> Lavender
    [const Color(0xFFEF4444), const Color(0xFFF97316)], // Red -> Orange
    [const Color(0xFF16A34A), const Color(0xFF059669)], // Green -> Emerald
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userName);
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('profile_name') ?? 'Productivity Champion';
      _avatarInitials = prefs.getString('profile_initials') ?? 'ME';
      _selectedGradientIndex = prefs.getInt('profile_gradient_index') ?? 0;
      _profileImagePath = prefs.getString('profile_image_path');
      _nameController.text = _userName;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _userName);
    await prefs.setString('profile_initials', _avatarInitials);
    await prefs.setInt('profile_gradient_index', _selectedGradientIndex);
    if (_profileImagePath != null) {
      await prefs.setString('profile_image_path', _profileImagePath!);
    } else {
      await prefs.remove('profile_image_path');
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setModalState(() {
          _profileImagePath = pickedFile.path;
        });
        setState(() {
          _profileImagePath = pickedFile.path;
        });
        await _saveProfileData();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final p = parts[0];
      return p.substring(0, p.length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  void _showAvatarEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: const Color(0xFFF97316),
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onBackground.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Customize Avatar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Live Preview
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: _profileImagePath != null
                            ? null
                            : LinearGradient(
                                colors: _gradientPresets[0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        image: _profileImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_profileImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _profileImagePath != null
                                ? Colors.black.withOpacity(0.1)
                                : _gradientPresets[0][0].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: _profileImagePath != null
                          ? null
                          : Center(
                              child: Text(
                                _getInitials(_userName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo Selection Buttons
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _pickImage(setModalState),
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: Text(_profileImagePath == null ? 'Choose Photo' : 'Change Photo'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                        if (_profileImagePath != null) ...[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                _profileImagePath = null;
                              });
                              setState(() {
                                _profileImagePath = null;
                              });
                              _saveProfileData();
                            },
                            icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.error),
                            label: Text('Remove', style: TextStyle(color: theme.colorScheme.error)),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Statistics calculations
    final int totalCount = widget.todos.length;
    
    final int completedCount = widget.todos.where((todo) {
      if (todo.isCompleted) return true;
      if (todo.completedDates.isNotEmpty) return true;
      if (todo.isCounter && todo.targetCount > 0) {
        final totalLogged = todo.dateCounts.values.fold(0, (sum, count) => sum + count);
        if (totalLogged >= todo.targetCount) return true;
      }
      return false;
    }).length;

    final double completionRate = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final int pendingCount = totalCount - completedCount;

    final int highPriorityPending = widget.todos.where((todo) => todo.priority == 'High' && !todo.isCompleted).length;

    final Map<String, List<Todo>> categoryGroups = {};
    for (var todo in widget.todos) {
      categoryGroups.putIfAbsent(todo.category, () => []).add(todo);
    }

    final categories = ['Work', 'Design', 'Fitness', 'Personal'];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onBackground.withOpacity(0.08),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'User Dashboard',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Card (Premium Gradient Look)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF97316),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Customizable Avatar
                      GestureDetector(
                        onTap: _showAvatarEditSheet,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: _profileImagePath != null
                                      ? null
                                      : LinearGradient(
                                          colors: _gradientPresets[0],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  image: _profileImagePath != null
                                      ? DecorationImage(
                                          image: FileImage(File(_profileImagePath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _profileImagePath != null
                                          ? Colors.black.withOpacity(0.1)
                                          : _gradientPresets[0][0].withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: _profileImagePath != null
                                    ? null
                                    : Center(
                                        child: Text(
                                          _getInitials(_userName),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Editable Name / Profile Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isEditingName)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      autofocus: true,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                                        border: UnderlineInputBorder(),
                                      ),
                                      onSubmitted: (val) {
                                        setState(() {
                                          if (val.trim().isNotEmpty) {
                                            _userName = val.trim();
                                          }
                                          _isEditingName = false;
                                        });
                                        _saveProfileData();
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (_nameController.text.trim().isNotEmpty) {
                                          _userName = _nameController.text.trim();
                                        }
                                        _isEditingName = false;
                                      });
                                      _saveProfileData();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _nameController.text = _userName;
                                        _isEditingName = false;
                                      });
                                    },
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _userName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingName = true;
                                      });
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.edit_rounded,
                                          size: 16,
                                          color: theme.colorScheme.onBackground.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'I alone am the honored one.',
                              style: TextStyle(
                                color: theme.colorScheme.onBackground.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),




            // Activity Chart
            SliverToBoxAdapter(
              child: _buildActivityChart(context),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chartTodos = widget.todos.where((todo) {
      if (_graphCategory == 'All') return true;
      return todo.category == _graphCategory;
    }).toList();

    final List<MapEntry<String, int>> dataPoints = [];
    final now = DateTime.now();

    if (_graphTimeframe == 'Week') {
      final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = "${date.year}-${date.month}-${date.day}";
        final label = dayNames[date.weekday - 1];
        
        final count = chartTodos.where((todo) => todo.completedDates.contains(dateKey)).length;
        dataPoints.add(MapEntry(label, count));
      }
    } else {
      for (int w = 3; w >= 0; w--) {
        int weekCount = 0;
        for (int d = 0; d < 7; d++) {
          final daysAgo = w * 7 + d;
          final date = now.subtract(Duration(days: daysAgo));
          final dateKey = "${date.year}-${date.month}-${date.day}";
          weekCount += chartTodos.where((todo) => todo.completedDates.contains(dateKey)).length;
        }
        dataPoints.add(MapEntry('Wk ${4 - w}', weekCount));
      }
    }

    final int maxVal = dataPoints.map((e) => e.value).fold(0, (max, v) => v > max ? v : max);
    final double scaleMax = maxVal == 0 ? 1.0 : maxVal.toDouble();

    Color barColor = theme.colorScheme.primary;
    if (_graphCategory == 'Work') barColor = Colors.blue;
    if (_graphCategory == 'Design') barColor = Colors.purple;
    if (_graphCategory == 'Fitness') barColor = Colors.green;
    if (_graphCategory == 'Personal') barColor = const Color(0xFFF97316);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onBackground.withOpacity(0.04),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completion History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onBackground.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: ['Week', 'Month'].map((tf) {
                      final isSelected = _graphTimeframe == tf;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _graphTimeframe = tf;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          child: Text(
                            tf,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.onBackground
                                  : theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['All', 'Work', 'Design', 'Fitness', 'Personal'].map((cat) {
                  final isSelected = _graphCategory == cat;
                  Color catColor = theme.colorScheme.primary;
                  if (cat == 'Work') catColor = Colors.blue;
                  if (cat == 'Design') catColor = Colors.purple;
                  if (cat == 'Fitness') catColor = Colors.green;
                  if (cat == 'Personal') catColor = const Color(0xFFF97316);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _graphCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? catColor.withOpacity(0.12) : theme.colorScheme.onBackground.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected ? catColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          if (cat != 'All') ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: catColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? catColor : theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dataPoints.map((dp) {
                  final double barHeight = (dp.value.toDouble() / scaleMax) * 110.0;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (dp.value > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${dp.value}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: barColor,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                        
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _graphTimeframe == 'Week' ? 24 : 36,
                          height: barHeight == 0 ? 4 : barHeight,
                          decoration: BoxDecoration(
                            gradient: barHeight == 0
                                ? null
                                : LinearGradient(
                                    colors: [barColor, barColor.withOpacity(0.6)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            color: barHeight == 0 ? theme.colorScheme.onBackground.withOpacity(0.08) : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          dp.key,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
