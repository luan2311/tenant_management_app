class RentalRequestModel {
  final int? id;
  final String? firestoreId;
  final int roomId;
  final String roomNumber;
  final String userUid; // Firebase Auth User UID
  final String fullName;
  final String phone;
  final String cccd;
  final String? hometown;
  final String startDate; // YYYY-MM-DD
  final int occupants;
  final String status; // 'pending', 'approved', 'rejected'
  final String createdAt; // YYYY-MM-DD HH:MM:SS
  final String? roommates; // JSON String representing roommate details

  RentalRequestModel({
    this.id,
    this.firestoreId,
    required this.roomId,
    required this.roomNumber,
    required this.userUid,
    required this.fullName,
    required this.phone,
    required this.cccd,
    this.hometown,
    required this.startDate,
    this.occupants = 1,
    this.status = 'pending',
    required this.createdAt,
    this.roommates,
  });

  factory RentalRequestModel.fromMap(Map<String, dynamic> map, {int? localId}) {
    return RentalRequestModel(
      id: localId ?? map['id'] as int?,
      firestoreId: map['firestore_id'] as String?,
      roomId: map['room_id'] as int,
      roomNumber: map['room_number'] as String? ?? '',
      userUid: map['user_uid'] as String? ?? map['user_id']?.toString() ?? '',
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      cccd: map['cccd'] as String,
      hometown: map['hometown'] as String?,
      startDate: map['start_date'] as String,
      occupants: map['occupants'] as int? ?? 1,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String,
      roommates: map['roommates'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestore_id': firestoreId,
      'room_id': roomId,
      'room_number': roomNumber,
      'user_uid': userUid,
      'full_name': fullName,
      'phone': phone,
      'cccd': cccd,
      'hometown': hometown,
      'start_date': startDate,
      'occupants': occupants,
      'status': status,
      'created_at': createdAt,
      'roommates': roommates,
    };
  }

  RentalRequestModel copyWith({
    int? id,
    String? firestoreId,
    int? roomId,
    String? roomNumber,
    String? userUid,
    String? fullName,
    String? phone,
    String? cccd,
    String? hometown,
    String? startDate,
    int? occupants,
    String? status,
    String? createdAt,
    String? roommates,
  }) {
    return RentalRequestModel(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      userUid: userUid ?? this.userUid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      cccd: cccd ?? this.cccd,
      hometown: hometown ?? this.hometown,
      startDate: startDate ?? this.startDate,
      occupants: occupants ?? this.occupants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      roommates: roommates ?? this.roommates,
    );
  }
}
