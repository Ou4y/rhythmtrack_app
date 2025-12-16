import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import 'edit_habit_screen.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final int habitId;
  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitProvider);

    final habit = state.habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
        id: habitId,
        name: 'Unknown',
        color: 0xFF2196F3,
        icon: 'check',
        reminderEnabled: false,
      ),
    );

    final currentStreak = state.streaks[habit.id!] ?? 0;

    const weekdayShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const monthNames = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];

    Color parseColor(dynamic colorValue) {
      if (colorValue is int) return Color(colorValue);
      return Colors.blue;
    }

    IconData getIconData(dynamic iconValue) {
      if (iconValue is String) {
        final code = int.tryParse(iconValue);
        if (code != null) return IconData(code, fontFamily: 'MaterialIcons');
        final iconMap = {
          'meditation': Icons.self_improvement,
          'read': Icons.book,
          'water': Icons.water_drop,
          'exercise': Icons.fitness_center,
          'sleep': Icons.bedtime,
          'code': Icons.code,
          'walk': Icons.directions_walk,
          'cook': Icons.restaurant,
        };
        return iconMap[iconValue.toLowerCase()] ?? Icons.check_circle;
      }
      return Icons.check_circle;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        centerTitle: true, 
        title: const Text(
          'Habit Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHabitScreen(habitId: habit.id!),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: parseColor(habit.color),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  getIconData(habit.icon),
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              habit.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Current & Longest Streak
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Text('Current Streak'),
                        const SizedBox(height: 8),
                        Text('$currentStreak days',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Text('Longest Streak'),
                        const SizedBox(height: 8),
                        FutureBuilder<int>(
                          future: ref.read(habitRepositoryProvider).longestStreak(habit.id!),
                          builder: (context, snap) {
                            final longest = snap.data ?? 0;
                            return Text('$longest days',
                                style: const TextStyle(fontWeight: FontWeight.bold));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // This Week Overview
            Text('This Week', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, bool>>(
              future: ref.read(habitRepositoryProvider).weeklyOverview(habit.id!),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final map = snap.data!;
                final days = map.keys.toList();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((d) {
                    final done = map[d]!;
                    final dt = DateTime.parse(d);
                    final label = weekdayShort[dt.weekday - 1];
                    return Column(
                      children: [
                        Text(label),
                        const SizedBox(height: 6),
                        Container(
                          width: 8,
                          height: done ? 36 : 16,
                          decoration: BoxDecoration(
                            color: done ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Month Overview
            Text('${monthNames[DateTime.now().month - 1]} ${DateTime.now().year}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, bool>>(
              future: ref.read(habitRepositoryProvider).weeklyOverview(habit.id!, days: 30),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final map = snap.data!;
                final first = DateTime(DateTime.now().year, DateTime.now().month, 1);
                final daysInMonth = DateUtils.getDaysInMonth(first.year, first.month);
                final widgets = <Widget>[];

                for (var i = 1; i <= daysInMonth; i++) {
                  final dt = DateTime(first.year, first.month, i);
                  final key =
                      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                  final done = map[key] ?? false;

                  widgets.add(Container(
                    margin: const EdgeInsets.all(6),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? Colors.blue : Colors.grey[200],
                    ),
                    child: Center(
                      child: Text(i.toString(),
                          style: TextStyle(
                              color: done ? Colors.white : Colors.black87)),
                    ),
                  ));
                }

                return Wrap(children: widgets);
              },
            ),
            const SizedBox(height: 20),

            // Reminder info
            ListTile(
              tileColor: Colors.white,
              title: const Text('Reminder'),
              trailing: Text(
                habit.reminderEnabled && habit.reminderTime != null
                    ? habit.reminderTime!
                    : 'Disabled',
                style: TextStyle(
                  color: habit.reminderEnabled && habit.reminderTime != null
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

           
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  await ref.read(habitRepositoryProvider).deleteHabit(habit.id!);
                  await ref.read(habitProvider.notifier).loadHabits();
                  if (!context.mounted) return;
                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                },
                child: const Text('Delete Habit', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
