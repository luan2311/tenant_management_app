import 'dart:ui';
import 'package:flutter/material.dart';

class AddContractScreen extends StatelessWidget {
  const AddContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Thêm hợp đồng mới', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thêm hợp đồng mới',
                style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Điền thông tin chi tiết để tạo hợp đồng thuê phòng mới tại hệ thống Lumiere Stay.',
                style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              
              // Khung Glassmorphism chứa Form
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Thông tin khách thuê
                        _buildSectionTitle(Icons.person_outline, 'Thông tin khách thuê'),
                        _buildInputField(label: 'Tên khách', hint: 'Nhập họ và tên khách'),
                        _buildDropdownField(label: 'Số phòng', hint: 'Chọn phòng trống'),
                        
                        const SizedBox(height: 16),
                        // Section 2: Điều khoản & Thời hạn
                        _buildSectionTitle(Icons.calendar_today_outlined, 'Điều khoản & Thời hạn'),
                        _buildInputField(label: 'Ngày tạo hợp đồng', hint: 'mm/dd/yyyy', isDate: true),
                        _buildDropdownField(label: 'Thời hạn hợp đồng', hint: '6 tháng'),
                        
                        const SizedBox(height: 16),
                        // Section 3: Chỉ số tiện ích ban đầu
                        _buildSectionTitle(Icons.speed_outlined, 'Chỉ số tiện ích ban đầu'),
                        _buildInputField(label: 'Chỉ số điện (Kwh)', hint: '0.00', isNumber: true),
                        _buildInputField(label: 'Chỉ số nước (m³)', hint: '0.00', isNumber: true),
                        
                        const SizedBox(height: 24),
                        // Hệ thống nút bấm hành động
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A7D96),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_edu, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Tạo hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black54)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFDCEAF1),
            child: Icon(icon, size: 16, color: const Color(0xFF4A7D96)),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, bool isNumber = false, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
              suffixIcon: isDate ? const Icon(Icons.calendar_month, color: Colors.black38, size: 20) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFEDF2F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFEDF2F6), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hint, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black87)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black38),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
