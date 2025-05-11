import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final Database database;

  ReportRepositoryImpl(this.database);

  @override
  Future<Report> generateReport({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = await _fetchReportData(type, startDate, endDate);
    return Report(
      type: type,
      startDate: startDate,
      endDate: endDate,
      data: data,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReportData(
    String type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final formattedStartDate = dateFormatter.format(startDate);
    final formattedEndDate = dateFormatter.format(endDate);

    switch (type) {
      case 'drivers':
        return await database.query(
          'drivers',
          where: 'joinDate BETWEEN ? AND ?',
          whereArgs: [formattedStartDate, formattedEndDate],
        );
      default:
        throw UnimplementedError('Report type $type not implemented');
    }
  }

  @override
  Future<Uint8List> generatePdf(Report report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('${report.type} Report'),
          ),
          pw.Header(
            level: 1,
            child: pw.Text(
              'Period: ${DateFormat('yyyy-MM-dd').format(report.startDate)} - ${DateFormat('yyyy-MM-dd').format(report.endDate)}',
            ),
          ),
          pw.Table.fromTextArray(
            headers: report.data.first.keys.toList(),
            data: report.data.map((item) => item.values.toList()).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
