import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/app_limit.dart';

class AppLimitService {
  static final AppLimitService instance = AppLimitService._init();
  AppLimitService._init();

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> saveLimit(AppLimit limit) async {
    final db = await _db;

    await db.insert(
      'app_limits',
      limit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppLimit>> getAllLimits() async {
    final db = await _db;
    final result = await db.query('app_limits');

    return result.map((map) => AppLimit.fromMap(map)).toList();
  }

  Future<AppLimit?> getLimit(String packageName) async {
    final db = await _db;

    final result = await db.query(
      'app_limits',
      where: 'packageName = ?',
      whereArgs: [packageName],
    );

    if (result.isNotEmpty) {
      return AppLimit.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteLimit(String packageName) async {
    final db = await _db;

    await db.delete(
      'app_limits',
      where: 'packageName = ?',
      whereArgs: [packageName],
    );
  }
}