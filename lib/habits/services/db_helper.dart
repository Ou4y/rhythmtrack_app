import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';

/// DBHelper supports injection of a [DatabaseFactory] and an optional
/// override path to make testing with sqflite_common_ffi easy. If
/// [databaseFactory] is null the normal `openDatabase` & `getDatabasesPath`
/// are used for production.
class DBHelper {
  final DatabaseFactory? databaseFactory;
  final String? overridePath;

  DBHelper({this.databaseFactory, this.overridePath});

  static const _dbName = 'habits.db';
  static const _dbVersion = 1;

  static const habitTable = 'habits';
  static const completionTable = 'habit_completion';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = overridePath ?? join(await getDatabasesPath(), _dbName);

    if (databaseFactory != null) {
      // use injected factory (sqflite_common_ffi in tests)
      return await databaseFactory!.openDatabase(path, options: OpenDatabaseOptions(version: _dbVersion, onCreate: _onCreate));
    }

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $habitTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        color INTEGER,
        reminderEnabled INTEGER,
        reminderTime TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $completionTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL,
        createdAt TEXT,
        FOREIGN KEY(habitId) REFERENCES $habitTable(id) ON DELETE CASCADE
      )
    ''');
  }

  // Habits CRUD
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert(habitTable, habit.toMap());
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(habitTable, habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    // delete completions first (cascade may do it but ensure)
    await db.delete(completionTable, where: 'habitId = ?', whereArgs: [id]);
    return await db.delete(habitTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final rows = await db.query(habitTable, orderBy: 'createdAt DESC');
    return rows.map((r) => Habit.fromMap(r)).toList();
  }

  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final rows = await db.query(habitTable, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Habit.fromMap(rows.first);
  }

  // Completions
  Future<HabitCompletion?> getCompletion(int habitId, String date) async {
    final db = await database;
    final rows = await db.query(completionTable, where: 'habitId = ? AND date = ?', whereArgs: [habitId, date]);
    if (rows.isEmpty) return null;
    return HabitCompletion.fromMap(rows.first);
  }

  Future<int> insertCompletion(HabitCompletion c) async {
    final db = await database;
    return await db.insert(completionTable, c.toMap());
  }

  Future<int> updateCompletion(HabitCompletion c) async {
    final db = await database;
    return await db.update(completionTable, c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> toggleCompletion(int habitId, String date, {bool completed = true}) async {
    final db = await database;
    final existing = await getCompletion(habitId, date);
    if (existing != null) {
      return await db.update(completionTable, {'completed': completed ? 1 : 0}, where: 'id = ?', whereArgs: [existing.id]);
    }
    final c = HabitCompletion(habitId: habitId, date: date, completed: completed);
    return await db.insert(completionTable, c.toMap());
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(int habitId) async {
    final db = await database;
    final rows = await db.query(completionTable, where: 'habitId = ?', whereArgs: [habitId], orderBy: 'date ASC');
    return rows.map((r) => HabitCompletion.fromMap(r)).toList();
  }

  Future<List<HabitCompletion>> getCompletionsInRange(int habitId, String startDate, String endDate) async {
    final db = await database;
    final rows = await db.query(
      completionTable,
      where: 'habitId = ? AND date BETWEEN ? AND ?',
      whereArgs: [habitId, startDate, endDate],
      orderBy: 'date ASC',
    );
    return rows.map((r) => HabitCompletion.fromMap(r)).toList();
  }
}
