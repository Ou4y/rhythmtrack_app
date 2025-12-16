import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/db_helper.dart';

class HabitRepository {
  final DBHelper db;

  HabitRepository(this.db);

  Future<List<Habit>> getAllHabits() => db.getHabits();

  Future<Habit?> getHabit(int id) => db.getHabitById(id);

  Future<int> createHabit(Habit habit) => db.insertHabit(habit);

  Future<int> updateHabit(Habit habit) => db.updateHabit(habit);

  Future<int> deleteHabit(int id) => db.deleteHabit(id);

  Future<HabitCompletion?> getCompletion(int habitId, DateTime date) {
    final iso = _dateToIso(date);
    return db.getCompletion(habitId, iso);
  }

  Future<int> toggleCompletion(int habitId, DateTime date, {bool completed = true}) {
    final iso = _dateToIso(date);
    return db.toggleCompletion(habitId, iso, completed: completed);
  }

  Future<List<HabitCompletion>> getCompletions(int habitId) => db.getCompletionsForHabit(habitId);

  Future<List<HabitCompletion>> getCompletionsInRange(int habitId, DateTime start, DateTime end) {
    final s = _dateToIso(start);
    final e = _dateToIso(end);
    return db.getCompletionsInRange(habitId, s, e);
  }

  // Helper to get last N days overview (list of dates and completed flag)
  Future<Map<String, bool>> weeklyOverview(int habitId, {int days = 7, DateTime? asOf}) async {
    final end = _dateOnly(asOf ?? DateTime.now());
    final start = end.subtract(Duration(days: days - 1));
    final comps = await getCompletionsInRange(habitId, start, end);
    final map = <String, bool>{};
    final compDates = {for (var c in comps) c.date: c.completed};
    for (var i = 0; i < days; i++) {
      final d = _dateToIso(start.add(Duration(days: i)));
      map[d] = compDates[d] ?? false;
    }
    return map;
  }

  Future<int> currentStreak(int habitId, {DateTime? asOf}) async {
    final today = _dateOnly(asOf ?? DateTime.now());
    final comps = await getCompletions(habitId);
    final completedDates = comps.where((c) => c.completed).map((c) => c.date).toSet();

    var streak = 0;
    var cursor = today;
    while (true) {
      final iso = _dateToIso(cursor);
      if (completedDates.contains(iso)) {
        streak++;
        cursor = cursor.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<int> longestStreak(int habitId) async {
    final comps = await getCompletions(habitId);
    final completed = comps.where((c) => c.completed).map((c) => c.date).toList()..sort();
    if (completed.isEmpty) return 0;

    int longest = 0;
    int current = 1;
    for (var i = 1; i < completed.length; i++) {
      final prev = DateTime.parse(completed[i - 1]);
      final cur = DateTime.parse(completed[i]);
      if (cur.difference(prev).inDays == 1) {
        current++;
      } else {
        if (current > longest) longest = current;
        current = 1;
      }
    }
    if (current > longest) longest = current;
    return longest;
  }

  String _dateToIso(DateTime d) {
    final dt = _dateOnly(d);
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
