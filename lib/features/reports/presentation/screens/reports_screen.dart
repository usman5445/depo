import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../providers/reports_notifier.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _reportType = 'drivers';

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(reportsProvider.notifier).generateReport(
          type: _reportType,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _printReport() async {
    final pdfData = await ref.read(reportsProvider.notifier).generatePdf();
    if (pdfData == null) return;

    await Printing.layoutPdf(
      onLayout: (_) async => pdfData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Report Content (3/4)
          Expanded(
            flex: 3,
            child: SizedBox.expand(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final reportState = ref.watch(reportsProvider);

                    return reportState.when(
                      data: (report) {
                        if (report == null) {
                          return const Center(
                            child:
                                Text('अहवाल पाहण्यासाठी कृपया अहवाल तयार करा'),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'अहवाल प्रीव्ह्यू',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(report.startDate)} ते ${DateFormat('yyyy-MM-dd').format(report.endDate)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 24),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: report.data.first.keys
                                      .map(
                                          (key) => DataColumn(label: Text(key)))
                                      .toList(),
                                  rows: report.data
                                      .map(
                                        (row) => DataRow(
                                          cells: row.values
                                              .map((value) => DataCell(
                                                  Text(value.toString())))
                                              .toList(),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Center(
                        child: Text('त्रुटी: $error'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Right side - Report Controls (1/4)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'अहवाल निर्माण',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'अहवाल प्रकार',
                          border: OutlineInputBorder(),
                        ),
                        value: _reportType,
                        items: const [
                          DropdownMenuItem(
                            value: 'drivers',
                            child: Text('चालक यादी'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reportType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'सुरुवात तारीख',
                            border: OutlineInputBorder(),
                          ),
                          child:
                              Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _endDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'समाप्ती तारीख',
                            border: OutlineInputBorder(),
                          ),
                          child:
                              Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                        ),
                      ),
                      const Spacer(),
                      Consumer(
                        builder: (context, ref, child) {
                          final reportState = ref.watch(reportsProvider);
                          final hasReport = reportState.value != null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FilledButton.icon(
                                onPressed: _generateReport,
                                icon: const Icon(Icons.preview),
                                label: const Text('अहवाल तयार करा'),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed: hasReport ? _printReport : null,
                                icon: const Icon(Icons.print),
                                label: const Text('छापा'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
