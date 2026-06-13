import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';

class MyInvoiceScreen extends StatefulWidget {
  const MyInvoiceScreen({super.key});

  @override
  State<MyInvoiceScreen> createState() => _MyInvoiceScreenState();
}

class _MyInvoiceScreenState extends State<MyInvoiceScreen> {
  int _selectedTab = 0; // 0: Chưa thanh toán, 1: Đã thanh toán

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeData = appState.activeRoomData;

    // Check if the tenant doesn't have active room data
    if (activeData == null || activeData['contract'] == null || activeData['room'] == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Hóa đơn của tôi', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Color(0xFF94A3B8)),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có hóa đơn nào',
                    style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Danh sách hóa đơn tiền phòng sẽ hiển thị tại đây sau khi chủ trọ tạo hóa đơn hàng tháng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final List<dynamic> allInvoices = activeData['invoices'] as List<dynamic>? ?? [];
    final room = activeData['room'];
    final roomNumber = room['room_number'] as String? ?? '';
    final double roomPrice = (room['price'] as num).toDouble();

    // Filter invoices by tab
    final statusFilter = _selectedTab == 0 ? 'unpaid' : 'paid';
    final filteredInvoices = allInvoices.where((inv) => inv['status'] == statusFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Hóa đơn của tôi - Lumiere', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hóa đơn của bạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text('Quản lý và thanh toán các khoản phí lưu trú.', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 20),

            // Tab Selection Header
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _selectedTab == 0
                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Chưa thanh toán',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0 ? const Color(0xFF0F172A) : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _selectedTab == 1
                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Đã thanh toán',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1 ? const Color(0xFF0F172A) : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Invoices List
            Expanded(
              child: filteredInvoices.isEmpty
                  ? Center(
                      child: Text(
                        _selectedTab == 0
                            ? 'Không có hóa đơn chưa thanh toán'
                            : 'Không có hóa đơn đã thanh toán',
                        style: const TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black38, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredInvoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        final int invoiceId = invoice['id'] as int;
                        final String billingMonth = invoice['billing_month'] as String;
                        final double oldElec = (invoice['old_electricity'] as num).toDouble();
                        final double newElec = (invoice['new_electricity'] as num).toDouble();
                        final double oldWater = (invoice['old_water'] as num).toDouble();
                        final double newWater = (invoice['new_water'] as num).toDouble();
                        final double elecPrice = (invoice['electricity_price'] as num).toDouble();
                        final double waterPrice = (invoice['water_price'] as num).toDouble();
                        final double servicePrice = (invoice['service_price'] as num? ?? 0.0).toDouble();
                        final double otherPrice = (invoice['other_price'] as num? ?? 0.0).toDouble();
                        final double totalPrice = (invoice['total_price'] as num).toDouble();
                        final String? paymentDate = invoice['payment_date'] as String?;

                        final double elecCost = (newElec - oldElec) * elecPrice;
                        final double waterCost = (newWater - oldWater) * waterPrice;

                        final roomPriceStr = _formatCurrency(roomPrice);
                        final elecCostStr = _formatCurrency(elecCost);
                        final waterCostStr = _formatCurrency(waterCost);
                        final serviceStr = _formatCurrency(servicePrice);
                        final otherStr = _formatCurrency(otherPrice);
                        final totalStr = _formatCurrency(totalPrice);

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tháng $billingMonth', style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedTab == 0
                                            ? 'Hạn thanh toán: Mùng 5 hàng tháng'
                                            : 'Thanh toán vào: $paymentDate',
                                        style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0 ? const Color(0xFFFECACA) : const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _selectedTab == 0 ? Icons.error_outline : Icons.check_circle_outline,
                                          color: _selectedTab == 0 ? const Color(0xFFB91C1C) : const Color(0xFF065F46),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedTab == 0 ? 'Chưa thanh\ntoán' : 'Đã thanh\ntoán',
                                          style: TextStyle(
                                            fontFamily: 'Be Vietnam Pro',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedTab == 0 ? const Color(0xFFB91C1C) : const Color(0xFF065F46),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 12),

                              _buildFeeRow('Tiền phòng ($roomNumber)', null, roomPriceStr),
                              _buildFeeRow('Tiền điện', 'Chỉ số: ${oldElec.toInt()} - ${newElec.toInt()} (${(newElec - oldElec).toInt()} kWh) · ${_formatCurrency(elecPrice)}/kWh', elecCostStr),
                              _buildFeeRow('Tiền nước', 'Chỉ số: ${oldWater.toInt()} - ${newWater.toInt()} (${(newWater - oldWater).toInt()} m³) · ${_formatCurrency(waterPrice)}/m³', waterCostStr),
                              _buildFeeRow('Dịch vụ', '(Internet, giữ xe, rác...)', serviceStr),
                              if (otherPrice > 0) _buildFeeRow('Chi phí khác', 'Chi phí phụ thêm', otherStr),
                              
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 16),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tổng cộng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(totalStr, style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                                ],
                              ),
                              if (_selectedTab == 0) ...[
                                const SizedBox(height: 24),
                                // Action Button: Pay Now
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A7D96),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      appState.markInvoicePaid(invoiceId).then((success) {
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Thanh toán hóa đơn thành công!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Gặp lỗi khi thanh toán. Vui lòng thử lại.'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.payments_outlined, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Thanh toán hóa đơn', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                        );
                      },
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

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }
}