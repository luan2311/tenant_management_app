// File: lib/views/admin/invoice_admin_screen.dart
import 'package:flutter/material.dart';

class InvoiceAdminScreen extends StatelessWidget {
  const InvoiceAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Hóa đơn - Lumiere Stay', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.maybePop(context),
      ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hóa đơn tháng 10', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text('Quản lý các khoản thanh toán trong tháng hiện tại.', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 20),

            // Card Tổng Doanh Thu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TỔNG DOANH THU', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45)),
                  const SizedBox(height: 4),
                  const Text('48.500.000đ', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text('+12% so với tháng trước', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w500)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút Tạo hóa đơn hàng loạt
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7DD3FC), Color(0xFF3B82F6)]), borderRadius: BorderRadius.circular(24)),
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.add, color: Colors.white)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tạo hóa đơn hàng loạt', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Tự động tính cho toàn bộ phòng trống.', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danh sách hóa đơn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách hóa đơn', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Text('Tháng 10', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.filter_list, size: 16),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInvoiceItem('Phòng 101 - Nguyen Van An', '15/10/2023', '3.500.000đ', true),
            _buildInvoiceItem('Phòng 204 - Tran Thi Bich', '16/10/2023', '4.200.000đ', false),
            _buildInvoiceItem('Phòng 302 - Le Hoang Nam', '16/10/2023', '3.850.000đ', true),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(String title, String date, String price, bool isPaid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.meeting_room, color: Color(0xFF0284C7)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFBAE6FD) : const Color(0xFFFECACA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPaid ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN',
                  style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 9, fontWeight: FontWeight.bold, color: isPaid ? const Color(0xFF0369A1) : const Color(0xFFB91C1C)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}