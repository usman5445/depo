import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../../../core/providers.dart';

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<Report?>>(
  (ref) => ReportsNotifier(ref.watch(reportRepositoryProvider)),
);

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ReportRepositoryImpl(database);
});

class ReportsNotifier extends StateNotifier<AsyncValue<Report?>> {
  final ReportRepository _repository;

  ReportsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> generateReport({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final report = await _repository.generateReport(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(report);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Uint8List?> generatePdf() async {
    try {
      final report = state.value;
      if (report == null) return null;
      return await _repository.generatePdf(report);
    } catch (error) {
      return null;
    }
  }
}
