// File: lib/views/tenant/my_invoice_screen.dart
import 'package:flutter/material.dart';

class MyInvoiceScreen extends StatelessWidget {
  const MyInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Hóa đơn của tôi - Lumiere', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hóa đơn của bạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text('Quản lý và thanh toán các khoản phí lưu trú.', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 20),

            // Tab chọn
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                      child: const Center(child: Text('Chưa thanh toán', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                    ),
                  ),
                  const Expanded(
                    child: Center(child: Text('Đã thanh toán', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hóa đơn chi tiết tháng hiện tại
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tháng 10, 2023', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Hạn thanh toán:\n05/11/2023', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFFECACA), borderRadius: BorderRadius.circular(16)),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 14),
                            SizedBox(width: 4),
                            Text('Chưa thanh\ntoán', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  _buildFeeRow('Tiền phòng (P.302)', null, '4,500,000 đ'),
                  _buildFeeRow('Điện', 'Chỉ số: 1020 - 1105 (85 kWh)', '297,500 đ'),
                  _buildFeeRow('Nước', 'Chỉ số: 152 - 157 (5 khối)', '75,000 đ'), // <-- Đã sửa Logic thành số khối
                  _buildFeeRow('Dịch vụ', '(Rác, Internet, Giữ xe)', '150,000 đ'),
                  
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng cộng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('5,022,500 đ', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nút thanh toán
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payments_outlined, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Thanh toán ngay', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String title, String? subtitle, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                ]
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}