import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/backup_info.dart';
import '../providers/backup_notifier.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final _backupNameController = TextEditingController();
  BackupInfo? _selectedBackup;
  int? _selectedRowIndex;

  @override
  void dispose() {
    _backupNameController.dispose();
    super.dispose();
  }

  Future<void> _createBackup() async {
    final name = _backupNameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(backupProvider.notifier).createBackup(name);
    _backupNameController.clear();
  }

  Future<void> _restoreBackup() async {
    if (_selectedBackup == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पुनर्संचयित करण्याची पुष्टी करा'),
        content:
            const Text('तुम्हाला नक्की हा बॅकअप पुनर्संचयित करायचा आहे का?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द करा'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('पुनर्संचयित करा'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(backupProvider.notifier).restoreBackup(_selectedBackup!);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('पुनर्संचयित यशस्वी'),
            content: const Text(
                'बॅकअप यशस्वीरित्या पुनर्संचयित केला गेला आहे. बदल लागू करण्यासाठी अॅप रीस्टार्ट करणे आवश्यक आहे.'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Use a better way to restart the app
                },
                child: const Text('पुन्हा सुरु करा'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _deleteBackup() async {
    if (_selectedBackup == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('हटवण्याची पुष्टी करा'),
        content: const Text(
            'तुम्हाला नक्की हा बॅकअप हटवायचा आहे का? हे परत येऊ शकत नाही.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द करा'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('हटवा'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(backupProvider.notifier).deleteBackup(_selectedBackup!);
      setState(() {
        _selectedBackup = null;
        _selectedRowIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Backups List (3/4)
          Expanded(
            flex: 3,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Consumer(
                builder: (context, ref, child) {
                  final backupsState = ref.watch(backupProvider);

                  return backupsState.when(
                    data: (backups) {
                      if (backups.isEmpty) {
                        return const Center(
                          child: Text('कोणतेही बॅकअप उपलब्ध नाहीत'),
                        );
                      }

                      return SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('नाव')),
                            DataColumn(label: Text('तारीख')),
                          ],
                          rows: List<DataRow>.generate(
                            backups.length,
                            (index) {
                              final backup = backups[index];
                              return DataRow(
                                selected: _selectedRowIndex == index,
                                onSelectChanged: (_) {
                                  setState(() {
                                    _selectedRowIndex = index;
                                    _selectedBackup = backup;
                                  });
                                },
                                cells: [
                                  DataCell(Text(backup.name)),
                                  DataCell(Text(
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(backup.date),
                                  )),
                                ],
                              );
                            },
                          ),
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

          // Right side - Backup Controls (1/4)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'बॅकअप व्यवस्थापन',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _backupNameController,
                      decoration: const InputDecoration(
                        labelText: 'बॅकअप नाव',
                        hintText: 'बॅकअप नाव प्रविष्ट करा',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _createBackup,
                      icon: const Icon(Icons.backup),
                      label: const Text('नवीन बॅकअप तयार करा'),
                    ),
                    if (_selectedBackup != null) ...[
                      const SizedBox(height: 32),
                      Text(
                        'निवडलेला बॅकअप',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('नाव: ${_selectedBackup!.name}'),
                              Text(
                                'तारीख: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedBackup!.date)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _restoreBackup,
                        icon: const Icon(Icons.restore),
                        label: const Text('पुनर्संचयित करा'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _deleteBackup,
                        icon: const Icon(Icons.delete),
                        label: const Text('हटवा'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
