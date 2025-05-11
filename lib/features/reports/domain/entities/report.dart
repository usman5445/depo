class Report {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> data;

  const Report({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
  });
}
