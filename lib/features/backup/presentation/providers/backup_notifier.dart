import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../../../core/providers.dart';

final backupProvider =
    StateNotifierProvider<BackupNotifier, AsyncValue<List<BackupInfo>>>(
  (ref) => BackupNotifier(ref.watch(backupRepositoryProvider)),
);

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BackupRepositoryImpl(database);
});

class BackupNotifier extends StateNotifier<AsyncValue<List<BackupInfo>>> {
  final BackupRepository _repository;

  BackupNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBackups();
  }

  Future<void> loadBackups() async {
    state = const AsyncValue.loading();
    try {
      final backups = await _repository.getBackups();
      state = AsyncValue.data(backups);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> selectBackupLocation() async {
    try {
      return await _repository.selectBackupLocation();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> createBackup({String? customDirectory}) async {
    try {
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      await _repository.createBackup('Backup',
          customDirectory: customDirectory);
      await loadBackups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> restoreBackup(BackupInfo backup) async {
    try {
      await _repository.restoreBackup(backup);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBackup(BackupInfo backup) async {
    try {
      await _repository.deleteBackup(backup);
      await loadBackups();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
