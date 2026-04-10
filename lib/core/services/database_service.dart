import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'app.db');

    // ❌ SUPPRIMÉ : deleteDatabase

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE transactions(
          id TEXT,
          title TEXT,
          amount REAL,
          isIncome INTEGER,
          category TEXT,
          date TEXT,
          accountName TEXT
        )
        ''');
      },
    );

    return _db!;
  }
}