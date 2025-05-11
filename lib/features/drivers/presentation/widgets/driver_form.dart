import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/driver.dart';

class DriverFormDialog extends StatefulWidget {
  final Driver? existingDriver;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController licenseController;
  final TextEditingController joinDateController;
  final Function(Driver) onSave;

  const DriverFormDialog({
    super.key,
    this.existingDriver,
    required this.nameController,
    required this.phoneController,
    required this.licenseController,
    required this.joinDateController,
    required this.onSave,
  });

  @override
  State<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends State<DriverFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingDriver?.joinDate != null) {
      _selectedDate =
          DateFormat('yyyy-MM-dd').parse(widget.existingDriver!.joinDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existingDriver == null ? 'चालक जोडा' : 'चालक संपादित करा'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: widget.nameController,
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
                controller: widget.phoneController,
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
                controller: widget.licenseController,
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
              ListTile(
                title: const Text('सामील होण्याची तारीख'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
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
                      widget.joinDateController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('रद्द करा'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final driver = Driver(
                id: widget.existingDriver?.id,
                name: widget.nameController.text,
                phone: widget.phoneController.text,
                license: widget.licenseController.text,
                joinDate: widget.joinDateController.text,
              );
              widget.onSave(driver);
              Navigator.pop(context);
            }
          },
          child: const Text('जतन करा'),
        ),
      ],
    );
  }
}
