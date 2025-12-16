import 'package:rhythmtrack_app/features/habits/models/habit.dart';

class HabitView {
  final Habit habit;
  final bool isDoneToday;
  final int currentStreak;
  final int longestStreak;

  HabitView({
    required this.habit,
    required this.isDoneToday,
    required this.currentStreak,
    required this.longestStreak,
  });
}
