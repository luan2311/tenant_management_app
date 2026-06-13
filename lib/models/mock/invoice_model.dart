class InvoiceModel {
  final int? id;
  final int roomId;
  final int contractId;
  final String billingMonth; // Định dạng YYYY-MM
  final double oldElectricity;
  final double newElectricity;
  final double oldWater;
  final double newWater;
  final double electricityPrice;
  final double waterPrice;
  final double servicePrice;
  final double otherPrice;
  final double totalPrice;
  final String status; // paid, unpaid
  final String? paymentDate;

  InvoiceModel({
    this.id,
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

  // Khớp chính xác với các cột trong bảng invoices của SQLite
  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int?,
      roomId: map['room_id'] as int,
      contractId: map['contract_id'] as int,
      billingMonth: map['billing_month'] as String,
      oldElectricity: (map['old_electricity'] as num).toDouble(),
      newElectricity: (map['new_electricity'] as num).toDouble(),
      oldWater: (map['old_water'] as num).toDouble(),
      newWater: (map['new_water'] as num).toDouble(),
      electricityPrice: (map['electricity_price'] as num).toDouble(),
      waterPrice: (map['water_price'] as num).toDouble(),
      servicePrice: (map['service_price'] as num?)?.toDouble() ?? 0.0,
      otherPrice: (map['other_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: map['status'] as String,
      paymentDate: map['payment_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
}