class ContractModel {
  final int? id;
  final int roomId;
  final int tenantId;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final double deposit;
  final double initialElectricity;
  final double initialWater;
  final String status; // 'active', 'expired', 'terminated'

  ContractModel({
    this.id,
    required this.roomId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.deposit,
    this.initialElectricity = 0.0,
    this.initialWater = 0.0,
    this.status = 'active',
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'] as int?,
      roomId: map['room_id'] as int,
      tenantId: map['tenant_id'] as int,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      deposit: (map['deposit'] as num).toDouble(),
      initialElectricity: (map['initial_electricity'] as num? ?? 0.0)
          .toDouble(),
      initialWater: (map['initial_water'] as num? ?? 0.0).toDouble(),
      status: map['status'] as String? ?? 'active',
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
      'initial_electricity': initialElectricity,
      'initial_water': initialWater,
      'status': status,
    };
  }

  ContractModel copyWith({
    int? id,
    int? roomId,
    int? tenantId,
    String? startDate,
    String? endDate,
    double? deposit,
    double? initialElectricity,
    double? initialWater,
    String? status,
  }) {
    return ContractModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      tenantId: tenantId ?? this.tenantId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deposit: deposit ?? this.deposit,
      initialElectricity: initialElectricity ?? this.initialElectricity,
      initialWater: initialWater ?? this.initialWater,
      status: status ?? this.status,
    );
  }
}
