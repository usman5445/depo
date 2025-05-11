class Driver {
  final int? id;
  final String name;
  final String phone;
  final String license;
  final String joinDate;

  Driver({
    this.id,
    required this.name,
    required this.phone,
    required this.license,
    required this.joinDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'license': license,
      'joinDate': joinDate,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      license: map['license'],
      joinDate: map['joinDate'],
    );
  }
}
