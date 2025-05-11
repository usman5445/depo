import 'package:flutter/foundation.dart';
import '../entities/report.dart';

abstract class ReportRepository {
  Future<Report> generateReport({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Uint8List> generatePdf(Report report);
}
