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

  void _showAvatarEditSheet() {
    String tempInitials = _avatarInitials;
    int tempGradientIndex = _selectedGradientIndex;
    final initialsController = TextEditingController(text: tempInitials);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: theme.colorScheme.onBackground.withOpacity(0.08),
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
                                colors: _gradientPresets[tempGradientIndex],
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
                                : _gradientPresets[tempGradientIndex][0].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: _profileImagePath != null
                          ? null
                          : Center(
                              child: Text(
                                tempInitials.toUpperCase(),
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

                  // Initials Input
                  Text(
                    'Initials',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: initialsController,
                    maxLength: 2,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter initials (e.g. ME)',
                      counterText: '',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        tempInitials = val.isEmpty ? '?' : val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gradient Chooser
                  Text(
                    'Theme Gradient',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _gradientPresets.length,
                      itemBuilder: (context, index) {
                        final isSelected = tempGradientIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempGradientIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _gradientPresets[index],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _avatarInitials = tempInitials.trim().isEmpty ? 'ME' : tempInitials;
                          _selectedGradientIndex = tempGradientIndex;
                        });
                        _saveProfileData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Customization',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
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
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                          : [const Color(0xFFEFF6FF), const Color(0xFFFAE8FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
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
                                          colors: _gradientPresets[_selectedGradientIndex],
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
                                          : _gradientPresets[_selectedGradientIndex][0].withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: _profileImagePath != null
                                    ? null
                                    : Center(
                                        child: Text(
                                          _avatarInitials.toUpperCase(),
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
                                      color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEFF6FF),
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
                              'Keep rising, one task at a time.',
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

            // Statistics Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Tasks',
                    value: '$totalCount',
                    icon: Icons.assignment_rounded,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Completed',
                    value: '$completedCount',
                    icon: Icons.check_circle_rounded,
                    color: theme.colorScheme.tertiary,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Completion',
                    value: '${(completionRate * 100).toStringAsFixed(0)}%',
                    icon: Icons.percent_rounded,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Pending',
                    value: '$pendingCount',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF97316),
                  ),
                ],
              ),
            ),

            // Category Breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Category breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  categories.map((category) {
                    final catTodos = categoryGroups[category] ?? [];
                    final int catTotal = catTodos.length;
                    final int catCompleted = catTodos.where((todo) => todo.isCompleted).length;
                    final double catProgress = catTotal == 0 ? 0.0 : catCompleted / catTotal;

                    Color catColor = const Color(0xFFF97316);
                    if (category == 'Work') catColor = Colors.blue;
                    if (category == 'Design') catColor = Colors.purple;
                    if (category == 'Fitness') catColor = Colors.green;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: theme.colorScheme.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.04)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: catColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$catCompleted / $catTotal completed',
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: catProgress,
                                minHeight: 6,
                                backgroundColor: theme.colorScheme.onBackground.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(catColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // High Priority Tasks Highlight
            if (highPriorityPending > 0) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Urgent Attention Required',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    widget.todos
                        .where((todo) => todo.priority == 'High' && !todo.isCompleted)
                        .map((todo) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.red.withOpacity(isDark ? 0.08 : 0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.red.withOpacity(0.2)),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.priority_high, color: Colors.red),
                                title: Text(
                                  todo.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Category: ${todo.category}',
                                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title, required String value, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.04),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
