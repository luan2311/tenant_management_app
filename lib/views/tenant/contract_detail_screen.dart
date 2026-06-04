import 'dart:ui';
import 'package:flutter/material.dart';

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black87),
        title: const Text('Hợp đồng của bạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: const Text('Phòng 302 • Khu A', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black45)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFD0E7F5), borderRadius: BorderRadius.circular(12)),
                      child: const Text('• Đang hiệu lực', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Color(0xFF2B6CB0), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    const Text('Hợp đồng Thuê phòng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Mã HĐ: #ES-2023-302', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 12),
                    
                    // Thẻ đếm ngược thời gian
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thời hạn còn lại', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                          Row(
                            children: [
                              Text('4 ', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B6CB0))),
                              Text('tháng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(Icons.calendar_today, 'Ngày bắt đầu', '01/08/2023'),
                    _buildInfoRow(Icons.calendar_month, 'Ngày kết thúc', '01/08/2024'),
                    _buildInfoRow(Icons.payments_outlined, 'Tiền cọc', '5.000.000 VNĐ', subtitle: 'Đã nộp đủ'),
                    
                    const SizedBox(height: 16),
                    const Text('Tài liệu đính kèm', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    
                    // File đính kèm PDF
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: const Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HopDong_Phong302.pdf', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('PDF • 2.4 MB', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                              ],
                            ),
                          ),
                          Icon(Icons.visibility_outlined, color: Colors.black45),
                          SizedBox(width: 10),
                          Icon(Icons.download_outlined, color: Colors.black45),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // Hệ thống nút bấm dưới chân trang
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7D96),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {},
                child: const Text('Yêu cầu gia hạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                  SizedBox(width: 6),
                  Text('Ngưng hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.redAccent)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
              Text(value, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold)),
              if (subtitle != null) Text(subtitle, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}