import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("screen_time.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_limits (
        packageName TEXT PRIMARY KEY,
        appName TEXT NOT NULL,
        iconBase64 TEXT NOT NULL,
        limitMinutes INTEGER NOT NULL
      )
    ''');
  }

  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}