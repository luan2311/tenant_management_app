class TenantModel {
  final int? id;
  final int? userId;
  final String fullName;
  final String phone;
  final String cccd;
  final String? hometown;
  final String? startDate; // YYYY-MM-DD

  TenantModel({
    this.id,
    this.userId,
    required this.fullName,
    required this.phone,
    required this.cccd,
    this.hometown,
    this.startDate,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      cccd: map['cccd'] as String,
      hometown: map['hometown'] as String?,
      startDate: map['start_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'cccd': cccd,
      'hometown': hometown,
      'start_date': startDate,
    };
  }

  TenantModel copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? phone,
    String? cccd,
    String? hometown,
    String? startDate,
  }) {
    return TenantModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      cccd: cccd ?? this.cccd,
      hometown: hometown ?? this.hometown,
      startDate: startDate ?? this.startDate,
    );
  }
}
