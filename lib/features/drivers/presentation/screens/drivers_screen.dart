import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/driver.dart';
import '../providers/drivers_notifier.dart';

class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _joinDateController = TextEditingController();
  Driver? _selectedDriver;
  int? _selectedRowIndex;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _joinDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _licenseController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _joinDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      _selectedDriver = null;
    });
  }

  void _selectDriver(Driver driver) {
    setState(() {
      _selectedDriver = driver;
      _nameController.text = driver.name;
      _phoneController.text = driver.phone;
      _licenseController.text = driver.license;
      _selectedDate = DateFormat('yyyy-MM-dd').parse(driver.joinDate);
      _joinDateController.text = driver.joinDate;
    });
  }

  Future<void> _saveDriver() async {
    if (!_formKey.currentState!.validate()) return;

    final driver = Driver(
      id: _selectedDriver?.id,
      name: _nameController.text,
      phone: _phoneController.text,
      license: _licenseController.text,
      joinDate: _joinDateController.text,
    );

    if (_selectedDriver == null) {
      await ref.read(driversProvider.notifier).addDriver(driver);
    } else {
      await ref.read(driversProvider.notifier).updateDriver(driver);
    }

    _resetForm();
  }

  Future<void> _deleteDriver() async {
    if (_selectedDriver == null) return;

    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('हटवण्याची पुष्टी करा'),
            content: const Text('तुम्हाला नक्की चालक हटवायचा आहे का?'),
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
        ) ??
        false;

    if (confirm) {
      await ref
          .read(driversProvider.notifier)
          .deleteDriver(_selectedDriver!.id!);
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Data Table (3/4)
          Expanded(
            flex: 3,
            child: SizedBox.expand(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final driversState = ref.watch(driversProvider);

                    return driversState.when(
                      data: (drivers) {
                        return SingleChildScrollView(
                          child: DataTable(
                            showCheckboxColumn: true,
                            columns: const [
                              DataColumn(label: Text('नाव')),
                              DataColumn(label: Text('फोन')),
                              DataColumn(label: Text('परवाना')),
                              DataColumn(label: Text('सामील दिनांक')),
                            ],
                            rows: List<DataRow>.generate(
                              drivers.length,
                              (index) {
                                final driver = drivers[index];
                                return DataRow(
                                  selected: _selectedRowIndex == index,
                                  onSelectChanged: (_) {
                                    setState(() => _selectedRowIndex = index);
                                    _selectDriver(driver);
                                  },
                                  cells: [
                                    DataCell(Text(driver.name)),
                                    DataCell(Text(driver.phone)),
                                    DataCell(Text(driver.license)),
                                    DataCell(Text(driver.joinDate)),
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
          ),

          // Right side - Action Form (1/4)
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
                        _selectedDriver == null
                            ? 'नवीन चालक'
                            : 'चालक संपादित करा',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'नाव',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'कृपया चालकाचे नाव प्रविष्ट करा';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'फोन',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'कृपया फोन नंबर प्रविष्ट करा';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _licenseController,
                        decoration: const InputDecoration(
                          labelText: 'परवाना',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'कृपया परवाना क्रमांक प्रविष्ट करा';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _joinDateController.text =
                                  DateFormat('yyyy-MM-dd').format(date);
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'सामील दिनांक',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_joinDateController.text),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveDriver,
                              icon: Icon(_selectedDriver == null
                                  ? Icons.add
                                  : Icons.save),
                              label: Text(
                                  _selectedDriver == null ? 'जोडा' : 'जतन करा'),
                            ),
                          ),
                          if (_selectedDriver != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _deleteDriver,
                                icon: const Icon(Icons.delete),
                                label: const Text('हटवा'),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onError,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedDriver != null)
                        OutlinedButton.icon(
                          onPressed: _resetForm,
                          icon: const Icon(Icons.add),
                          label: const Text('नवीन चालक'),
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
