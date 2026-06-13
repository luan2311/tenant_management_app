import 'dart:convert';

class RoomModel {
  final int? id;
  final int? facilityId;
  final String roomNumber;
  final double price;
  final double deposit;
  final int maxTenants;
  final String status; // 'empty', 'rented', 'maintenance'
  final String description;
  final String? imageUrl;
  final List<String> amenities;

  RoomModel({
    this.id,
    this.facilityId,
    required this.roomNumber,
    required this.price,
    required this.deposit,
    this.maxTenants = 2,
    this.status = 'empty',
    this.description = '',
    this.imageUrl,
    this.amenities = const [],
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    List<String> amenitiesList = [];
    if (map['amenities'] != null && map['amenities'] is String) {
      try {
        final decoded = json.decode(map['amenities'] as String);
        if (decoded is List) {
          amenitiesList = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // Fallback split nếu dữ liệu cũ không phải JSON hợp lệ
        amenitiesList = (map['amenities'] as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return RoomModel(
      id: map['id'] as int?,
      facilityId: map['facility_id'] as int?,
      roomNumber: map['room_number'] as String,
      price: (map['price'] as num).toDouble(),
      deposit: (map['deposit'] as num).toDouble(),
      maxTenants: map['max_tenants'] as int? ?? 2,
      status: map['status'] as String? ?? 'empty',
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      amenities: amenitiesList,
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
      'description': description,
      'image_url': imageUrl,
      'amenities': json.encode(amenities),
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
    String? description,
    String? imageUrl,
    List<String>? amenities,
  }) {
    return RoomModel(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      roomNumber: roomNumber ?? this.roomNumber,
      price: price ?? this.price,
      deposit: deposit ?? this.deposit,
      maxTenants: maxTenants ?? this.maxTenants,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      amenities: amenities ?? this.amenities,
    );
  }
}
