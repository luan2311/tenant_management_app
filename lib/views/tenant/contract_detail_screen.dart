import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/services/firestore_sync_service.dart';

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeData = appState.activeRoomData;

    // Check if the tenant doesn't have an active contract
    if (activeData == null || activeData['contract'] == null || activeData['room'] == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('Hợp đồng của bạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 80, color: Color(0xFF94A3B8)),
                  SizedBox(height: 16),
                  Text(
                    'Bạn chưa có hợp đồng nào',
                    style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hợp đồng thuê phòng sẽ được khởi tạo khi bạn thuê phòng thành công.',
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

    final contract = activeData['contract'];
    final room = activeData['room'];

    final int contractId = contract['id'] as int;
    final String roomNumber = room['room_number'] as String? ?? '';
    final String startDateStr = contract['start_date'] as String? ?? '';
    final String endDateStr = contract['end_date'] as String? ?? '';
    final double deposit = (contract['deposit'] as num).toDouble();
    final double initialElectricity = (contract['initial_electricity'] as num? ?? 0.0).toDouble();
    final double initialWater = (contract['initial_water'] as num? ?? 0.0).toDouble();
    final String status = contract['status'] as String? ?? 'active';

    final depositStr = '${deposit.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';

    // Calculate time remaining
    final end = DateTime.tryParse(endDateStr) ?? DateTime.now();
    final now = DateTime.now();
    final remainingDays = end.difference(now).inDays;
    String timeRemainingStr = '';
    if (remainingDays <= 0) {
      timeRemainingStr = 'Đã hết hạn';
    } else if (remainingDays < 30) {
      timeRemainingStr = '$remainingDays ngày';
    } else {
      timeRemainingStr = '${(remainingDays / 30).ceil()} tháng';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hợp đồng của bạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Phòng $roomNumber • Lumiere Stay', style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black45)),
          ],
        ),
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'active' ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status == 'active' ? '• Đang hiệu lực' : '• Ngưng hiệu lực',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 12,
                            color: status == 'active' ? const Color(0xFF065F46) : Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Hợp đồng Thuê phòng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Mã HĐ: #LUMIERE-HĐ-$contractId', style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 12, color: Colors.black45)),
                      const SizedBox(height: 12),
                      
                      // Thẻ đếm ngược thời gian
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Thời hạn còn lại', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                            Row(
                              children: [
                                Text(
                                  timeRemainingStr.split(' ').first,
                                  style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E6486)),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeRemainingStr.contains(' ') ? timeRemainingStr.split(' ').last : '',
                                  style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow(Icons.calendar_today, 'Ngày bắt đầu', startDateStr),
                      _buildInfoRow(Icons.calendar_month, 'Ngày kết thúc', endDateStr),
                      _buildInfoRow(Icons.payments_outlined, 'Tiền cọc phòng', depositStr, subtitle: 'Đã nộp đủ cho chủ trọ'),
                      _buildInfoRow(Icons.electric_bolt, 'Số điện ban đầu', '${initialElectricity.toStringAsFixed(1)} kWh'),
                      _buildInfoRow(Icons.water_drop, 'Số nước ban đầu', '${initialWater.toStringAsFixed(1)} m³'),
                      
                      const SizedBox(height: 16),
                      const Text('Tài liệu đính kèm', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      
                      // File đính kèm PDF
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HopDong_Phong$roomNumber.pdf', style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 13, fontWeight: FontWeight.bold)),
                                  const Text('PDF • 1.5 MB', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 11, color: Colors.black45)),
                                ],
                              ),
                            ),
                            const Icon(Icons.visibility_outlined, color: Colors.black45),
                            const SizedBox(width: 10),
                            const Icon(Icons.download_outlined, color: Colors.black45),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            
            // Hệ thống nút bấm dưới chân trang
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => _showTerminateRequestDialog(context, appState, contractId, roomNumber),
                      child: const Text('Ngưng hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7D96),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => _showExtendRequestDialog(context, appState, contractId, roomNumber),
                      child: const Text('Gia hạn hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExtendRequestDialog(BuildContext context, AppState appState, int contractId, String roomNumber) {
    int selectedMonths = 6;
    final tenantName = appState.currentUser?.fullName ?? 'Khách thuê';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yêu cầu gia hạn hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn thời gian gia hạn thêm:', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedMonths,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 tháng', style: TextStyle(fontFamily: 'Be Vietnam Pro'))),
                      DropdownMenuItem(value: 3, child: Text('3 tháng', style: TextStyle(fontFamily: 'Be Vietnam Pro'))),
                      DropdownMenuItem(value: 6, child: Text('6 tháng', style: TextStyle(fontFamily: 'Be Vietnam Pro'))),
                      DropdownMenuItem(value: 12, child: Text('12 tháng', style: TextStyle(fontFamily: 'Be Vietnam Pro'))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedMonths = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7D96)),
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Gửi thông báo tới admin trên Firestore
                    appState.setLoading(true);
                    try {
                      final title = 'Yêu cầu gia hạn hợp đồng';
                      final content = '$tenantName (Phòng $roomNumber) gửi yêu cầu gia hạn hợp đồng thêm $selectedMonths tháng. (Mã hợp đồng: $contractId, Số tháng: $selectedMonths)';
                      
                      await FirestoreSyncService.sendNotification(
                        userUid: 'admin',
                        title: title,
                        content: content,
                        type: 'booking_request',
                      );
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi yêu cầu gia hạn tới chủ trọ. Vui lòng chờ phê duyệt!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lỗi khi gửi yêu cầu. Vui lòng thử lại.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                    appState.setLoading(false);
                  },
                  child: const Text('Gửi yêu cầu', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showTerminateRequestDialog(BuildContext context, AppState appState, int contractId, String roomNumber) {
    final tenantName = appState.currentUser?.fullName ?? 'Khách thuê';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yêu cầu ngưng hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, color: Colors.redAccent)),
          content: const Text('Bạn có chắc chắn muốn gửi yêu cầu ngưng hợp đồng thuê phòng hiện tại? Hành động này sẽ được gửi tới chủ trọ để xác nhận trả phòng.', style: TextStyle(fontFamily: 'Be Vietnam Pro')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.pop(context);
                
                // Gửi thông báo tới admin trên Firestore
                appState.setLoading(true);
                try {
                  final title = 'Yêu cầu ngưng hợp đồng';
                  final content = '$tenantName (Phòng $roomNumber) gửi yêu cầu ngưng hợp đồng thuê. (Mã hợp đồng: $contractId)';
                  
                  await FirestoreSyncService.sendNotification(
                    userUid: 'admin',
                    title: title,
                    content: content,
                    type: 'booking_request',
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi yêu cầu ngưng hợp đồng tới chủ trọ. Vui lòng chờ phê duyệt!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lỗi khi gửi yêu cầu. Vui lòng thử lại.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
                appState.setLoading(false);
              },
              child: const Text('Xác nhận', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white)),
            ),
          ],
        );
      },
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
