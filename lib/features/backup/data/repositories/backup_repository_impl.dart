import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  final Database database;
  bool _isReopening = false;
  String? _customBackupDirectory;

  BackupRepositoryImpl(this.database);

  Future<String> get _backupDirectory async {
    if (_customBackupDirectory != null) {
      final dir = Directory(_customBackupDirectory!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return _customBackupDirectory!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<void> _closeDatabase() async {
    if (!database.isOpen) return;
    await database.close();
  }

  Future<void> _reopenDatabase(String path) async {
    if (_isReopening) return;
    _isReopening = true;
    try {
      await openDatabase(path);
    } finally {
      _isReopening = false;
    }
  }

  @override
  Future<BackupInfo> createBackup(String name,
      {String? customDirectory}) async {
    try {
      _customBackupDirectory = customDirectory;
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = '$timestamp.db';
      final backupPath = join(await _backupDirectory, fileName);

      // Check if backup already exists
      if (await File(backupPath).exists()) {
        throw Exception('A backup with this name already exists');
      }

      // Get the current database path
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'depo_database.db'));

      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Close the current database connection
      await _closeDatabase();

      try {
        // Copy the database file to backup location
        await dbFile.copy(backupPath);

        return BackupInfo(
          name: name,
          path: backupPath,
          date: DateTime.now(),
        );
      } finally {
        // Ensure database is reopened even if copy fails
        await _reopenDatabase(dbFile.path);
      }
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  @override
  Future<List<BackupInfo>> getBackups() async {
    try {
      final backupDir = Directory(await _backupDirectory);
      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .toList();

      return files
          .whereType<File>()
          .map((file) {
            try {
              final fileName = basename(file.path);
              final dateString = fileName.replaceAll('.db', '');

              return BackupInfo(
                name:
                    'Backup', // Using a generic name since we're using timestamp as filename
                path: file.path,
                date: DateTime.parse(dateString.replaceAll('-', ':')),
              );
            } catch (e) {
              // Skip invalid backup files
              return null;
            }
          })
          .where((backup) => backup != null)
          .cast<BackupInfo>()
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw Exception('Failed to retrieve backups: $e');
    }
  }

  @override
  Future<void> restoreBackup(BackupInfo backup) async {
    try {
      final backupFile = File(backup.path);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Get the database path
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'depo_database.db'));

      // Close the current database connection
      await _closeDatabase();

      try {
        // Copy the backup file to the database location
        await backupFile.copy(dbFile.path);
      } finally {
        // Ensure database is reopened even if restore fails
        await _reopenDatabase(dbFile.path);
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  @override
  Future<void> deleteBackup(BackupInfo backup) async {
    try {
      final file = File(backup.path);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      await file.delete();
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  @override
  Future<String> selectBackupLocation() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) {
      throw Exception('No directory selected');
    }
    _customBackupDirectory = result;
    return result;
  }
}
