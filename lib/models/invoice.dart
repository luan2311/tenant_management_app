class InvoiceModel {
  final int? id;
  final String? firestoreId;
  final int roomId;
  final int contractId;
  final String billingMonth; // YYYY-MM
  final double oldElectricity;
  final double newElectricity;
  final double oldWater;
  final double newWater;
  final double electricityPrice;
  final double waterPrice;
  final double servicePrice;
  final double otherPrice;
  final double totalPrice;
  final String status; // 'paid', 'unpaid'
  final String? paymentDate; // YYYY-MM-DD

  InvoiceModel({
    this.id,
    this.firestoreId,
    required this.roomId,
    required this.contractId,
    required this.billingMonth,
    required this.oldElectricity,
    required this.newElectricity,
    required this.oldWater,
    required this.newWater,
    required this.electricityPrice,
    required this.waterPrice,
    this.servicePrice = 0.0,
    this.otherPrice = 0.0,
    required this.totalPrice,
    this.status = 'unpaid',
    this.paymentDate,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int?,
      firestoreId: map['firestore_id'] as String?,
      roomId: map['room_id'] as int,
      contractId: map['contract_id'] as int,
      billingMonth: map['billing_month'] as String,
      oldElectricity: (map['old_electricity'] as num).toDouble(),
      newElectricity: (map['new_electricity'] as num).toDouble(),
      oldWater: (map['old_water'] as num).toDouble(),
      newWater: (map['new_water'] as num).toDouble(),
      electricityPrice: (map['electricity_price'] as num).toDouble(),
      waterPrice: (map['water_price'] as num).toDouble(),
      servicePrice: (map['service_price'] as num? ?? 0.0).toDouble(),
      otherPrice: (map['other_price'] as num? ?? 0.0).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      status: map['status'] as String? ?? 'unpaid',
      paymentDate: map['payment_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestore_id': firestoreId,
      'room_id': roomId,
      'contract_id': contractId,
      'billing_month': billingMonth,
      'old_electricity': oldElectricity,
      'new_electricity': newElectricity,
      'old_water': oldWater,
      'new_water': newWater,
      'electricity_price': electricityPrice,
      'water_price': waterPrice,
      'service_price': servicePrice,
      'other_price': otherPrice,
      'total_price': totalPrice,
      'status': status,
      'payment_date': paymentDate,
    };
  }

  InvoiceModel copyWith({
    int? id,
    String? firestoreId,
    int? roomId,
    int? contractId,
    String? billingMonth,
    double? oldElectricity,
    double? newElectricity,
    double? oldWater,
    double? newWater,
    double? electricityPrice,
    double? waterPrice,
    double? servicePrice,
    double? otherPrice,
    double? totalPrice,
    String? status,
    String? paymentDate,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      roomId: roomId ?? this.roomId,
      contractId: contractId ?? this.contractId,
      billingMonth: billingMonth ?? this.billingMonth,
      oldElectricity: oldElectricity ?? this.oldElectricity,
      newElectricity: newElectricity ?? this.newElectricity,
      oldWater: oldWater ?? this.oldWater,
      newWater: newWater ?? this.newWater,
      electricityPrice: electricityPrice ?? this.electricityPrice,
      waterPrice: waterPrice ?? this.waterPrice,
      servicePrice: servicePrice ?? this.servicePrice,
      otherPrice: otherPrice ?? this.otherPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}
