import '../entities/backup_info.dart';

abstract class BackupRepository {
  Future<BackupInfo> createBackup(String name, {String? customDirectory});
  Future<List<BackupInfo>> getBackups();
  Future<void> restoreBackup(BackupInfo backup);
  Future<void> deleteBackup(BackupInfo backup);
  Future<String> selectBackupLocation();
}
