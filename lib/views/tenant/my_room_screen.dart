import 'package:flutter/material.dart';
import 'my_invoice_screen.dart';
import 'contract_detail_screen.dart';

class MyRoomScreen extends StatelessWidget {
  const MyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text('Phòng của tôi', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Thông tin chi tiết và bạn cùng phòng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Thẻ thông tin phòng chính (Glassmorphic Card)
              _buildMainRoomCard(),
              const SizedBox(height: 16),
              
              // Thẻ hiển thị đơn giá Tiện ích
              _buildUtilitiesCard(),
              const SizedBox(height: 16),

              // Nút điều hướng nhanh
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyInvoiceScreen())),
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: const Text('Hóa đơn', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E6486),
                        side: const BorderSide(color: Color(0xFF2E6486)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractDetailScreen())),
                      icon: const Icon(Icons.assignment_outlined, size: 18),
                      label: const Text('Hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E6486),
                        side: const BorderSide(color: Color(0xFF2E6486)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Khu vực Người ở chung
              const Text('Người ở chung', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildRoommateRow('Phùng Tuấn Huy', 'Người đại diện', true),
                    _buildRoommateRow('Phạm Gia Khánh', 'Thành viên', false),
                    _buildEmptySlotRow(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainRoomCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4)]),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SỐ PHÒNG', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                const Text('P.402', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 4),
                const Text('Giá thuê / tháng: 4.500.000đ', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black87)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFBAE6FD), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Đang thuê', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text('Ngày thanh toán', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                const Text('Mùng 5 hàng tháng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUtilitiesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFEDF2F6), borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          UtilityRow(icon: Icons.electric_bolt, label: 'Điện', value: '3.500đ / kWh'),
          Divider(color: Colors.white),
          UtilityRow(icon: Icons.water_drop, label: 'Nước', value: '20.000đ / khối'),
          Divider(color: Colors.white),
          UtilityRow(icon: Icons.wifi, label: 'Internet', value: 'Miễn phí'),
        ],
      ),
    );
  }

  Widget _buildRoommateRow(String name, String role, bool isLeader) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 14)),
                Text(role, style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: isLeader ? const Color(0xFF4A7D96) : Colors.black45)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.phone_in_talk_outlined, size: 20, color: Colors.black54), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black54), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildEmptySlotRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_alt, color: Colors.black38, size: 18),
          SizedBox(width: 8),
          Text('Còn 1 chỗ trống', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black45, fontSize: 13)),
        ],
      ),
    );
  }
}

class UtilityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const UtilityRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A7D96)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54)),
          const Spacer(),
          Text(value, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
