import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'depo_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE drivers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, license TEXT, joinDate TEXT)',
        );
      },
      version: 1,
    );
  }
}
