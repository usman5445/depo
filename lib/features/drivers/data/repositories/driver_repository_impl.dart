import 'package:sqflite/sqflite.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final Database database;

  DriverRepositoryImpl(this.database);

  @override
  Future<List<Driver>> getAllDrivers() async {
    final List<Map<String, dynamic>> maps = await database.query('drivers');
    return maps.map((map) => Driver.fromMap(map)).toList();
  }

  @override
  Future<void> addDriver(Driver driver) async {
    await database.insert(
      'drivers',
      driver.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateDriver(Driver driver) async {
    await database.update(
      'drivers',
      driver.toMap(),
      where: 'id = ?',
      whereArgs: [driver.id],
    );
  }

  @override
  Future<void> deleteDriver(int id) async {
    await database.delete(
      'drivers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
