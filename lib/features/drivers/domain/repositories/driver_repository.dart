import '../entities/driver.dart';

abstract class DriverRepository {
  Future<List<Driver>> getAllDrivers();
  Future<void> addDriver(Driver driver);
  Future<void> updateDriver(Driver driver);
  Future<void> deleteDriver(int id);
}
