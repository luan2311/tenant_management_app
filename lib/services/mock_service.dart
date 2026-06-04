import '../models/contract_model.dart';
import '../models/invoice_model.dart';

class MockService {
  // Giả lập danh sách Hợp đồng để bàn giao cho tầng View
  static Future<List<ContractModel>> getMockContracts() async {
    await Future.delayed(const Duration(milliseconds: 400)); // Tạo độ trễ mượt mà giống DB thật
    return [
      ContractModel(
        id: 1, roomId: 1, tenantId: 10, 
        startDate: '2026-01-01', endDate: '2026-12-31', 
        deposit: 3000000.0, status: 'active'
      ),
      ContractModel(
        id: 2, roomId: 2, tenantId: 11, 
        startDate: '2025-06-01', endDate: '2026-06-01', 
        deposit: 2500000.0, status: 'expired'
      ),
    ];
  }

  // Giả lập danh sách Hóa đơn chưa thanh toán và đã thanh toán đúng nghiệp vụ tính tiền
  static Future<List<InvoiceModel>> getMockInvoices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      InvoiceModel(
        id: 1, roomId: 1, contractId: 1, billingMonth: '2026-05',
        oldElectricity: 1200.0, newElectricity: 1350.0, // Sử dụng 150 chữ điện
        oldWater: 450.0, newWater: 462.0,               // Sử dụng 12 khối nước
        electricityPrice: 3500.0, waterPrice: 15000.0,
        servicePrice: 100000.0, otherPrice: 50000.0,
        totalPrice: 855000.0, // Tổng tiền = (150*3500) + (12*15000) + 100000 + 50000
        status: 'unpaid'
      ),
    ];
  }
}