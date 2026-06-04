class ContractModel {
  final int? id;
  final int roomId;
  final int tenantId;
  final String startDate; // Định dạng YYYY-MM-DD
  final String endDate;   // Định dạng YYYY-MM-DD
  final double deposit;
  final String status;    // active, expired, terminated

  ContractModel({
    this.id,
    required this.roomId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.deposit,
    this.status = 'active',
  });

  // Khớp chính xác với các cột trong bảng contracts của SQLite
  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'] as int?,
      roomId: map['room_id'] as int,
      tenantId: map['tenant_id'] as int,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      deposit: (map['deposit'] as num).toDouble(), // Ép kiểu an toàn từ SQLite REAL
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'tenant_id': tenantId,
      'start_date': startDate,
      'end_date': endDate,
      'deposit': deposit,
      'status': status,
    };
  }
}