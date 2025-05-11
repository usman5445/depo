import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../features/drivers/data/repositories/driver_repository_impl.dart';
import '../features/drivers/domain/repositories/driver_repository.dart';
import '../features/reports/data/repositories/report_repository_impl.dart';
import '../features/reports/domain/repositories/report_repository.dart';
import '../features/backup/data/repositories/backup_repository_impl.dart';
import '../features/backup/domain/repositories/backup_repository.dart';
import '../services/database_service.dart';

final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('Database not initialized');
});

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DriverRepositoryImpl(database);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ReportRepositoryImpl(database);
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BackupRepositoryImpl(database);
});
