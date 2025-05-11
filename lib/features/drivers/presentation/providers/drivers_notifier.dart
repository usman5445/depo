import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../../../core/providers.dart';

final driversProvider =
    StateNotifierProvider<DriversNotifier, AsyncValue<List<Driver>>>(
  (ref) => DriversNotifier(
    ref.watch(driverRepositoryProvider),
  ),
);

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DriverRepositoryImpl(database);
});

class DriversNotifier extends StateNotifier<AsyncValue<List<Driver>>> {
  final DriverRepository _repository;

  DriversNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDrivers();
  }

  Future<void> loadDrivers() async {
    state = const AsyncValue.loading();
    try {
      final drivers = await _repository.getAllDrivers();
      state = AsyncValue.data(drivers);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addDriver(Driver driver) async {
    try {
      await _repository.addDriver(driver);
      await loadDrivers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateDriver(Driver driver) async {
    try {
      await _repository.updateDriver(driver);
      await loadDrivers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteDriver(int id) async {
    try {
      await _repository.deleteDriver(id);
      await loadDrivers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
