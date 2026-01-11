import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final int habitId;
  const EditHabitScreen({super.key, required this.habitId});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  Habit? _habit;
  String selectedIcon = 'meditation';
  String selectedColor = '#4CAF50';
  bool reminder = false;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);

  final List<Map<String, dynamic>> icons = const [
    {'name': 'meditation', 'icon': Icons.self_improvement},
    {'name': 'read', 'icon': Icons.book},
    {'name': 'exercise', 'icon': Icons.fitness_center},
    {'name': 'walk', 'icon': Icons.directions_walk},
    {'name': 'sleep', 'icon': Icons.bedtime},
    {'name': 'water', 'icon': Icons.water_drop},
    {'name': 'code', 'icon': Icons.code},
    {'name': 'cook', 'icon': Icons.restaurant},
  ];

  final List<String> colors = const [
    '#FF6B6B',
    '#FF9500',
    '#FFD93D',
    '#6BCB77',
    '#4D96FF',
    '#9D84B7',
    '#4CAF50',
  ];

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
    final h = await ref.read(habitRepositoryProvider).getHabit(widget.habitId);
    if (h != null) {
      _habit = h;
      _nameController.text = h.name;
      selectedColor = '#${h.color.toRadixString(16).substring(2).toUpperCase()}';
      selectedIcon = h.icon;
      reminder = h.reminderEnabled;
      if (h.reminderTime != null) {
        final parts = h.reminderTime!.split(':');
        if (parts.length == 2) {
          _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      if (mounted) setState(() {});
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse('0xFF${colorString.replaceFirst('#', '')}'));
    } catch (_) {
      return Colors.grey;
    }
  }

  int _colorToInt(String colorString) {
    try {
      return int.parse('0xFF${colorString.replaceFirst('#', '')}');
    } catch (_) {
      return 0xFF9E9E9E;
    }
  }

  Future<void> _saveChanges() async {
    if (_habit == null || _nameController.text.trim().isEmpty) return;

    final updated = _habit!.copyWith(
      name: _nameController.text.trim(),
      color: _colorToInt(selectedColor),
      icon: selectedIcon,
      reminderEnabled: reminder,
      reminderTime:
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
    );

    await ref.read(habitRepositoryProvider).updateHabit(updated);
    await ref.read(habitProvider.notifier).loadHabits();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? colorScheme.primary,
        foregroundColor: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary,
        elevation: theme.appBarTheme.elevation,
        title: Text('Edit Habit', style: theme.textTheme.titleLarge),
        shape: theme.appBarTheme.shape,
      ),
      body: _habit == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary.withOpacity(0.08), colorScheme.secondary.withOpacity(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter habit name',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icons
                      const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: icons.map((icon) {
                            final isSelected = selectedIcon == icon['name'];
                            return GestureDetector(
                              onTap: () => setState(() => selectedIcon = icon['name'] as String),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected ? colorScheme.primary : theme.cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(0.18),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Center(
                                    child: Icon(icon['icon'] as IconData,
                                        color: isSelected ? colorScheme.onPrimary : theme.iconTheme.color)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Colors
                      const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: colors.map((c) {
                            final isSelected = selectedColor == c;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = c),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _parseColor(c),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(width: 3, color: colorScheme.primary)
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reminder
                      SwitchListTile(
                        tileColor: theme.cardColor,
                        title: const Text('Reminder'),
                        value: reminder,
                        onChanged: (v) => setState(() => reminder = v),
                      ),
                      ListTile(
                        tileColor: theme.cardColor,
                        title: const Text('Time'),
                        trailing: Text(_time.format(context),
                            style: TextStyle(color: colorScheme.primary)),
                        onTap: () async {
                          final t = await showTimePicker(context: context, initialTime: _time);
                          if (t != null) setState(() => _time = t);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Save Changes Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveChanges,
                          child: Text('Save Changes', style: TextStyle(color: colorScheme.onPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
