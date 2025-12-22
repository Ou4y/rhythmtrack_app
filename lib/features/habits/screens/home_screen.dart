import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import 'add_habit_screen.dart';
import '../widgets/habit_card.dart';
import 'habit_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue is int) return Color(colorValue);
    if (colorValue is String) {
      try {
        return Color(int.parse(
            colorValue.startsWith('#')
                ? '0xFF${colorValue.replaceFirst('#', '')}'
                : colorValue));
      } catch (_) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  IconData _getIconData(dynamic iconValue) {
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

  void _openHabitDetails(BuildContext context, int habitId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitDetailsScreen(habitId: habitId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitProvider);
    final notifier = ref.read(habitProvider.notifier);

    const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    final now = DateTime.now();
    final date = '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
              child: const Text('Navigation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Habits Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Already on HomeScreen, so just pop drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Screen Time Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/screen_time_dashboard');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: state.habits.isEmpty
                        ? const Center(child: Text('No habits yet'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80, top: 8),
                            itemCount: state.habits.length,
                            itemBuilder: (context, i) {
                              final habit = state.habits[i];
                              return HabitCard(
                                habit: habit,
                                streak: state.streaks[habit.id] ?? 0,
                                isCompletedToday: state.completedToday[habit.id] ?? false,
                                color: _parseColor(habit.color),
                                icon: _getIconData(habit.icon),
                                onToggle: () => notifier.toggleHabit(habit),
                                onNameTap: () => _openHabitDetails(context, habit.id!),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        ),
        shape: const CircleBorder(), 
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
