class FacilityModel {
  final int? id;
  final String name;
  final String address;
  final int status; // 1: Active, 0: Suspended

  FacilityModel({
    this.id,
    required this.name,
    required this.address,
    this.status = 1,
  });

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    return FacilityModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      status: map['status'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status,
    };
  }

  FacilityModel copyWith({
    int? id,
    String? name,
    String? address,
    int? status,
  }) {
    return FacilityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }
}
