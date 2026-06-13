class ContractModel {
  final int? id;
  final int roomId;
  final int tenantId;
  final String startDate;
  final String endDate;
  final double deposit;
  final double initialElectricity; // Mới thêm theo image_3138bc.png
  final double initialWater;       // Mới thêm theo image_3138bc.png
  final String contractPdfPath;    // Mới thêm theo image_31405c.png
  final String status;

  ContractModel({
    this.id,
    required this.roomId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.deposit,
    required this.initialElectricity,
    required this.initialWater,
    required this.contractPdfPath,
    required this.status,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'] as int?,
      roomId: map['room_id'] as int,
      tenantId: map['tenant_id'] as int,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      deposit: (map['deposit'] as num).toDouble(),
      initialElectricity: (map['initial_electricity'] as num? ?? 0.0).toDouble(),
      initialWater: (map['initial_water'] as num? ?? 0.0).toDouble(),
      contractPdfPath: map['contract_pdf_path'] as String? ?? '',
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
      'initial_electricity': initialElectricity,
      'initial_water': initialWater,
      'contract_pdf_path': contractPdfPath,
      'status': status,
    };
  }
}