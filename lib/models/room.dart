class RoomModel {
  final int? id;
  final int? facilityId;
  final String roomNumber;
  final double price;
  final double deposit;
  final int maxTenants;
  final String status; // 'empty', 'rented', 'maintenance'

  RoomModel({
    this.id,
    this.facilityId,
    required this.roomNumber,
    required this.price,
    required this.deposit,
    this.maxTenants = 2,
    this.status = 'empty',
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] as int?,
      facilityId: map['facility_id'] as int?,
      roomNumber: map['room_number'] as String,
      price: (map['price'] as num).toDouble(),
      deposit: (map['deposit'] as num).toDouble(),
      maxTenants: map['max_tenants'] as int? ?? 2,
      status: map['status'] as String? ?? 'empty',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facility_id': facilityId,
      'room_number': roomNumber,
      'price': price,
      'deposit': deposit,
      'max_tenants': maxTenants,
      'status': status,
    };
  }

  RoomModel copyWith({
    int? id,
    int? facilityId,
    String? roomNumber,
    double? price,
    double? deposit,
    int? maxTenants,
    String? status,
  }) {
    return RoomModel(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      roomNumber: roomNumber ?? this.roomNumber,
      price: price ?? this.price,
      deposit: deposit ?? this.deposit,
      maxTenants: maxTenants ?? this.maxTenants,
      status: status ?? this.status,
    );
  }
}
