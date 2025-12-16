import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_application_1/feature/habits/services/db_helper.dart';
import 'package:flutter_application_1/feature/habits/repository/habit_repository.dart';
import 'package:flutter_application_1/feature/habits/models/habit.dart';

void main() {
  sqfliteFfiInit();

  late DBHelper dbHelper;
  late HabitRepository repo;

  setUp(() async {
    final factory = databaseFactoryFfi;
    // use in-memory database for tests
    dbHelper = DBHelper(databaseFactory: factory, overridePath: inMemoryDatabasePath);
    repo = HabitRepository(dbHelper);
  });

  tearDown(() async {
    // no explicit cleanup needed for in-memory DB, but close if open
    try {
      final db = await dbHelper.database;
      await db.close();
    } catch (_) {}
  });

  test('create, read, update, delete habit', () async {
    final habit = Habit(name: 'Read for 15 minutes');
    final id = await repo.createHabit(habit);
    expect(id, isNonZero);

    final all = await repo.getAllHabits();
    expect(all.length, 1);
    expect(all.first.name, 'Read for 15 minutes');

    final updated = all.first.copyWith(name: 'Read for 20 minutes');
    await repo.updateHabit(updated);
    final fetched = (await repo.getAllHabits()).first;
    expect(fetched.name, 'Read for 20 minutes');

    await repo.deleteHabit(fetched.id!);
    final afterDelete = await repo.getAllHabits();
    expect(afterDelete, isEmpty);
  });

  test('streak calculations', () async {
    final habit = Habit(name: 'Meditate 10 mins');
    final habitId = await repo.createHabit(habit);
    expect(habitId, isNonZero);

    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    final twoDaysAgo = today.subtract(Duration(days: 2));

    await repo.toggleCompletion(habitId, twoDaysAgo);
    await repo.toggleCompletion(habitId, yesterday);
    await repo.toggleCompletion(habitId, today);

    final current = await repo.currentStreak(habitId);
    final longest = await repo.longestStreak(habitId);

    expect(current, 3);
    expect(longest, greaterThanOrEqualTo(3));
  });
}
