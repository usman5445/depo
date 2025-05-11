class Driver {
  final int? id;
  final String name;
  final String phone;
  final String license;
  final String joinDate;

  const Driver({
    this.id,
    required this.name,
    required this.phone,
    required this.license,
    required this.joinDate,
  });

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      license: map['license'] as String,
      joinDate: map['joinDate'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'license': license,
      'joinDate': joinDate,
    };
  }

  Driver copyWith({
    int? id,
    String? name,
    String? phone,
    String? license,
    String? joinDate,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      license: license ?? this.license,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
