import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';

class DatabaseService {
  static Future<Database> initDatabase() async {
    final dbPath = await AppConstants.getDatabasePath();

    // Ensure the directory exists
    final dbDir = dirname(dbPath);
    await Directory(dbDir).create(recursive: true);

    return openDatabase(
      dbPath,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE drivers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, license TEXT, joinDate TEXT)',
        );
      },
      version: 1,
    );
  }
}
