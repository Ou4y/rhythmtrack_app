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
          _time = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }

      if (mounted) setState(() {});
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('0xFF${hex.replaceFirst('#', '')}'));
    } catch (_) {
      return Colors.grey;
    }
  }

  int _colorToInt(String hex) {
    try {
      return int.parse('0xFF${hex.replaceFirst('#', '')}');
    } catch (_) {
      return 0xFF9E9E9E;
    }
  }

  Future<void> _saveChanges() async {
    if (_habit == null || _nameController.text.trim().isEmpty) return;

    final updated = _habit!.copyWith(
      name: _nameController.text.trim(),
      icon: selectedIcon,
      color: _colorToInt(selectedColor),
      reminderEnabled: reminder,
      reminderTime:
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
    );

    await ref.read(habitRepositoryProvider).updateHabit(updated);
    await ref.read(habitProvider.notifier).loadHabits();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Habit', style: theme.textTheme.titleLarge),
        shape: theme.appBarTheme.shape,
      ),
      body: _habit == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section(
                      context,
                      title: 'Habit Name',
                      child: TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Enter habit name',
                        ),
                      ),
                    ),

                    _section(
                      context,
                      title: 'Icon',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: icons.map((icon) {
                          final selected = selectedIcon == icon['name'];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedIcon = icon['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: selected
                                    ? cs.primary
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? cs.primary
                                      : cs.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                icon['icon'],
                                color: selected
                                    ? cs.onPrimary
                                    : theme.iconTheme.color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    _section(
                      context,
                      title: 'Color',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: colors.map((c) {
                          final selected = selectedColor == c;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedColor = c),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _parseColor(c),
                                border: Border.all(
                                  width: selected ? 3 : 1,
                                  color: selected
                                      ? cs.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: selected
                                  ? const Icon(Icons.check,
                                      color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    _section(
                      context,
                      title: 'Reminder',
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: reminder,
                            title: const Text('Enable reminder'),
                            onChanged: (v) =>
                                setState(() => reminder = v),
                          ),
                          if (reminder)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Time'),
                              trailing: Text(
                                _time.format(context),
                                style: TextStyle(color: cs.primary),
                              ),
                              onTap: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: _time,
                                );
                                if (t != null) setState(() => _time = t);
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _saveChanges,
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
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

  Widget _section(BuildContext context,
      {required String title, required Widget child}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}