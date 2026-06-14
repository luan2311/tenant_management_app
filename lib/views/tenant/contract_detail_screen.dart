import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/services/firestore_sync_service.dart';
import 'contract_history_screen.dart';

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeData = appState.activeRoomData;

    // Check if the tenant doesn't have an active contract
    if (activeData == null ||
        activeData['contract'] == null ||
        activeData['room'] == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'Hợp đồng của bạn',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [_buildHistoryAction(context)],
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 80,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bạn chưa có hợp đồng nào',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hợp đồng thuê phòng sẽ được khởi tạo khi bạn thuê phòng thành công.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
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
    final double initialElectricity =
        (contract['initial_electricity'] as num? ?? 0.0).toDouble();
    final double initialWater = (contract['initial_water'] as num? ?? 0.0)
        .toDouble();
    final String status = contract['status'] as String? ?? 'active';

    final depositStr =
        '${deposit.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';

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
            const Text(
              'Hợp đồng của bạn',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Phòng $roomNumber • Lumiere Stay',
              style: const TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        actions: [_buildHistoryAction(context)],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'active'
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status == 'active'
                              ? '• Đang hiệu lực'
                              : '• Ngưng hiệu lực',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 12,
                            color: status == 'active'
                                ? const Color(0xFF065F46)
                                : Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Hợp đồng Thuê phòng',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mã HĐ: #LUMIERE-HĐ-$contractId',
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Thẻ đếm ngược thời gian
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thời hạn còn lại',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  timeRemainingStr.split(' ').first,
                                  style: const TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E6486),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeRemainingStr.contains(' ')
                                      ? timeRemainingStr.split(' ').last
                                      : '',
                                  style: const TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        Icons.calendar_today,
                        'Ngày bắt đầu',
                        startDateStr,
                      ),
                      _buildInfoRow(
                        Icons.calendar_month,
                        'Ngày kết thúc',
                        endDateStr,
                      ),
                      _buildInfoRow(
                        Icons.payments_outlined,
                        'Tiền cọc phòng',
                        depositStr,
                        subtitle: 'Đã nộp đủ cho chủ trọ',
                      ),
                      _buildInfoRow(
                        Icons.electric_bolt,
                        'Số điện ban đầu',
                        '${initialElectricity.toStringAsFixed(1)} kWh',
                      ),
                      _buildInfoRow(
                        Icons.water_drop,
                        'Số nước ban đầu',
                        '${initialWater.toStringAsFixed(1)} m³',
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Tài liệu đính kèm',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // File đính kèm PDF
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              _openContractPdfPreview(context, activeData),
                          child: Ink(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'HopDong_Phong$roomNumber.pdf',
                                        style: const TextStyle(
                                          fontFamily: 'Be Vietnam Pro',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'PDF • Tài liệu hợp đồng',
                                        style: TextStyle(
                                          fontFamily: 'Be Vietnam Pro',
                                          fontSize: 11,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Xem tài liệu',
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () => _openContractPdfPreview(
                                    context,
                                    activeData,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Tải xuống',
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.download_outlined,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () =>
                                      _downloadContractPdf(context, activeData),
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
            ),

            // Hệ thống nút bấm dưới chân trang
            const SizedBox(height: 16),
            // Chỉ cho gia hạn khi hợp đồng còn hiệu lực và sắp hết hạn (< 30 ngày).
            if (status == 'active' && remainingDays < 30)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => _showTerminateRequestDialog(
                          context,
                          appState,
                          contractId,
                          roomNumber,
                        ),
                        child: const Text(
                          'Ngưng hợp đồng',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => _showExtendRequestDialog(
                          context,
                          appState,
                          contractId,
                          roomNumber,
                        ),
                        child: const Text(
                          'Gia hạn hợp đồng',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (status == 'active')
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => _showTerminateRequestDialog(
                        context,
                        appState,
                        contractId,
                        roomNumber,
                      ),
                      child: const Text(
                        'Ngưng hợp đồng',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bạn có thể gia hạn hợp đồng khi còn dưới 30 ngày là hết hạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryAction(BuildContext context) {
    return IconButton(
      tooltip: 'Lịch sử hợp đồng',
      icon: const Icon(Icons.history, color: Colors.black87),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ContractHistoryScreen()),
      ),
    );
  }

  void _showExtendRequestDialog(
    BuildContext context,
    AppState appState,
    int contractId,
    String roomNumber,
  ) {
    int selectedMonths = 6;
    final tenantName = appState.currentUser?.fullName ?? 'Khách thuê';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Yêu cầu gia hạn hợp đồng',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn thời gian gia hạn thêm:',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedMonths,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          '1 tháng',
                          style: TextStyle(fontFamily: 'Be Vietnam Pro'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text(
                          '3 tháng',
                          style: TextStyle(fontFamily: 'Be Vietnam Pro'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 6,
                        child: Text(
                          '6 tháng',
                          style: TextStyle(fontFamily: 'Be Vietnam Pro'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 12,
                        child: Text(
                          '12 tháng',
                          style: TextStyle(fontFamily: 'Be Vietnam Pro'),
                        ),
                      ),
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
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7D96),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    // Gửi thông báo tới admin trên Firestore
                    appState.setLoading(true);
                    try {
                      final title = 'Yêu cầu gia hạn hợp đồng';
                      final content =
                          '$tenantName (Phòng $roomNumber) gửi yêu cầu gia hạn hợp đồng thêm $selectedMonths tháng. (Mã hợp đồng: $contractId, Số tháng: $selectedMonths)';

                      await FirestoreSyncService.sendNotification(
                        userUid: 'admin',
                        title: title,
                        content: content,
                        type: 'booking_request',
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã gửi yêu cầu gia hạn tới chủ trọ. Vui lòng chờ phê duyệt!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lỗi khi gửi yêu cầu. Vui lòng thử lại.',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                    appState.setLoading(false);
                  },
                  child: const Text(
                    'Gửi yêu cầu',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTerminateRequestDialog(
    BuildContext context,
    AppState appState,
    int contractId,
    String roomNumber,
  ) {
    final tenantName = appState.currentUser?.fullName ?? 'Khách thuê';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Yêu cầu ngưng hợp đồng',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn gửi yêu cầu ngưng hợp đồng thuê phòng hiện tại? Hành động này sẽ được gửi tới chủ trọ để xác nhận trả phòng.',
            style: TextStyle(fontFamily: 'Be Vietnam Pro'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.pop(context);

                // Gửi thông báo tới admin trên Firestore
                appState.setLoading(true);
                try {
                  final title = 'Yêu cầu ngưng hợp đồng';
                  final content =
                      '$tenantName (Phòng $roomNumber) gửi yêu cầu ngưng hợp đồng thuê. (Mã hợp đồng: $contractId)';

                  await FirestoreSyncService.sendNotification(
                    userUid: 'admin',
                    title: title,
                    content: content,
                    type: 'booking_request',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã gửi yêu cầu ngưng hợp đồng tới chủ trọ. Vui lòng chờ phê duyệt!',
                        ),
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
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openContractPdfPreview(
    BuildContext context,
    Map<String, dynamic> activeData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContractPdfPreviewScreen(activeData: activeData),
      ),
    );
  }

  Future<void> _downloadContractPdf(
    BuildContext context,
    Map<String, dynamic> activeData,
  ) async {
    final room = activeData['room'] as Map<String, dynamic>;
    final roomNumber = room['room_number'] as String? ?? 'unknown';
    final safeRoomNumber = roomNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    final fileName = 'HopDong_Phong$safeRoomNumber.pdf';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(_ContractPdfFileBuilder(activeData).build());

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tải $fileName vào ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải file PDF. Vui lòng thử lại.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContractPdfPreviewScreen extends StatelessWidget {
  const ContractPdfPreviewScreen({super.key, required this.activeData});

  final Map<String, dynamic> activeData;

  @override
  Widget build(BuildContext context) {
    final contract = activeData['contract'] as Map<String, dynamic>;
    final room = activeData['room'] as Map<String, dynamic>;
    final tenant = activeData['tenant'] as Map<String, dynamic>?;

    final contractId = contract['id'] as int? ?? 0;
    final roomNumber = room['room_number'] as String? ?? '';
    final tenantName = tenant?['full_name'] as String? ?? 'Khách thuê';
    final tenantPhone = tenant?['phone'] as String? ?? 'Chưa cập nhật';
    final tenantCccd = tenant?['cccd'] as String? ?? 'Chưa cập nhật';
    final startDate = contract['start_date'] as String? ?? '';
    final endDate = contract['end_date'] as String? ?? '';
    final deposit = (contract['deposit'] as num? ?? 0).toDouble();
    final roomPrice = (room['price'] as num? ?? 0).toDouble();
    final status = contract['status'] as String? ?? 'active';

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'HopDong_Phong$roomNumber.pdf',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Be Vietnam Pro',
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 680),
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'LUMIERE STAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E6486),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'HỢP ĐỒNG THUÊ PHÒNG',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mã hợp đồng: #LUMIERE-HĐ-$contractId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _PdfSection(
                    title: 'Thông tin phòng',
                    rows: [
                      _PdfRow('Phòng', 'Phòng $roomNumber'),
                      _PdfRow('Giá thuê hằng tháng', _formatMoney(roomPrice)),
                      _PdfRow('Tiền cọc', _formatMoney(deposit)),
                      _PdfRow(
                        'Trạng thái',
                        status == 'active' ? 'Đang hiệu lực' : 'Ngưng hiệu lực',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _PdfSection(
                    title: 'Thông tin khách thuê',
                    rows: [
                      _PdfRow('Họ và tên', tenantName),
                      _PdfRow('Số điện thoại', tenantPhone),
                      _PdfRow('CCCD', tenantCccd),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _PdfSection(
                    title: 'Thời hạn hợp đồng',
                    rows: [
                      _PdfRow('Ngày bắt đầu', startDate),
                      _PdfRow('Ngày kết thúc', endDate),
                      _PdfRow(
                        'Chỉ số điện ban đầu',
                        '${(contract['initial_electricity'] as num? ?? 0).toStringAsFixed(1)} kWh',
                      ),
                      _PdfRow(
                        'Chỉ số nước ban đầu',
                        '${(contract['initial_water'] as num? ?? 0).toStringAsFixed(1)} m³',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Tài liệu này được hiển thị từ dữ liệu hợp đồng đang lưu trong hệ thống Lumiere Stay. Khi có file PDF gốc được tải lên, màn hình này có thể mở trực tiếp file đính kèm đó.',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(child: _SignatureBlock(title: 'Bên cho thuê')),
                      const SizedBox(width: 16),
                      Expanded(child: _SignatureBlock(title: 'Bên thuê')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatMoney(double value) {
    final text = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$text VNĐ';
  }
}

class _PdfRow {
  const _PdfRow(this.label, this.value);

  final String label;
  final String value;
}

class _PdfSection extends StatelessWidget {
  const _PdfSection({required this.title, required this.rows});

  final String title;
  final List<_PdfRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: rows.map((row) {
              final isLast = row == rows.last;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 132,
                      child: Text(
                        row.label,
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SignatureBlock extends StatelessWidget {
  const _SignatureBlock({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 52),
        Container(height: 1, color: const Color(0xFFCBD5E1)),
      ],
    );
  }
}

class _ContractPdfFileBuilder {
  const _ContractPdfFileBuilder(this.activeData);

  final Map<String, dynamic> activeData;

  List<int> build() {
    final content = _buildPageContent();
    final contentBytes = ascii.encode(content);
    final objects = <String>[
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
      '<< /Length ${contentBytes.length} >>\nstream\n$content\nendstream',
    ];

    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[0];

    for (var i = 0; i < objects.length; i++) {
      offsets.add(ascii.encode(buffer.toString()).length);
      buffer
        ..write('${i + 1} 0 obj\n')
        ..write(objects[i])
        ..write('\nendobj\n');
    }

    final xrefOffset = ascii.encode(buffer.toString()).length;
    buffer
      ..write('xref\n')
      ..write('0 ${objects.length + 1}\n')
      ..write('0000000000 65535 f \n');

    for (final offset in offsets.skip(1)) {
      buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    buffer
      ..write('trailer\n')
      ..write('<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
      ..write('startxref\n')
      ..write('$xrefOffset\n')
      ..write('%%EOF\n');

    return ascii.encode(buffer.toString());
  }

  String _buildPageContent() {
    final contract = activeData['contract'] as Map<String, dynamic>;
    final room = activeData['room'] as Map<String, dynamic>;
    final tenant = activeData['tenant'] as Map<String, dynamic>?;

    final contractId = contract['id'] as int? ?? 0;
    final roomNumber = room['room_number'] as String? ?? '';
    final tenantName = tenant?['full_name'] as String? ?? 'Khach thue';
    final tenantPhone = tenant?['phone'] as String? ?? 'Chua cap nhat';
    final tenantCccd = tenant?['cccd'] as String? ?? 'Chua cap nhat';
    final startDate = contract['start_date'] as String? ?? '';
    final endDate = contract['end_date'] as String? ?? '';
    final deposit = (contract['deposit'] as num? ?? 0).toDouble();
    final roomPrice = (room['price'] as num? ?? 0).toDouble();
    final status = contract['status'] as String? ?? 'active';
    final electricity = (contract['initial_electricity'] as num? ?? 0)
        .toStringAsFixed(1);
    final water = (contract['initial_water'] as num? ?? 0).toStringAsFixed(1);

    final lines = <_PdfTextLine>[
      _PdfTextLine('LUMIERE STAY', 20, 220, 790),
      _PdfTextLine('HOP DONG THUE PHONG', 18, 190, 760),
      _PdfTextLine('Ma hop dong: #LUMIERE-HD-$contractId', 11, 205, 738),
      _PdfTextLine('Thong tin phong', 14, 72, 700),
      _PdfTextLine('Phong: Phong $roomNumber', 11, 92, 678),
      _PdfTextLine(
        'Gia thue hang thang: ${_formatMoney(roomPrice)}',
        11,
        92,
        660,
      ),
      _PdfTextLine('Tien coc: ${_formatMoney(deposit)}', 11, 92, 642),
      _PdfTextLine(
        'Trang thai: ${status == 'active' ? 'Dang hieu luc' : 'Ngung hieu luc'}',
        11,
        92,
        624,
      ),
      _PdfTextLine('Thong tin khach thue', 14, 72, 586),
      _PdfTextLine('Ho va ten: $tenantName', 11, 92, 564),
      _PdfTextLine('So dien thoai: $tenantPhone', 11, 92, 546),
      _PdfTextLine('CCCD: $tenantCccd', 11, 92, 528),
      _PdfTextLine('Thoi han hop dong', 14, 72, 490),
      _PdfTextLine('Ngay bat dau: $startDate', 11, 92, 468),
      _PdfTextLine('Ngay ket thuc: $endDate', 11, 92, 450),
      _PdfTextLine('Chi so dien ban dau: $electricity kWh', 11, 92, 432),
      _PdfTextLine('Chi so nuoc ban dau: $water m3', 11, 92, 414),
      _PdfTextLine(
        'Tai lieu duoc tao tu du lieu hop dong trong he thong Lumiere Stay.',
        10,
        72,
        360,
      ),
      _PdfTextLine('Ben cho thue', 11, 125, 270),
      _PdfTextLine('Ben thue', 11, 375, 270),
      _PdfTextLine('____________________', 11, 92, 210),
      _PdfTextLine('____________________', 11, 342, 210),
    ];

    final buffer = StringBuffer();
    for (final line in lines) {
      buffer.write(_drawText(line.text, line.fontSize, line.x, line.y));
    }
    return buffer.toString();
  }

  String _drawText(String text, num fontSize, num x, num y) {
    return 'BT /F1 $fontSize Tf 1 0 0 1 $x $y Tm (${_escapePdfText(_asciiText(text))}) Tj ET\n';
  }

  String _escapePdfText(String text) {
    return text
        .replaceAll(r'\', r'\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)');
  }

  String _formatMoney(double value) {
    final text = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$text VND';
  }

  String _asciiText(String value) {
    const replacements = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
      'À': 'A',
      'Á': 'A',
      'Ạ': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ầ': 'A',
      'Ấ': 'A',
      'Ậ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ă': 'A',
      'Ằ': 'A',
      'Ắ': 'A',
      'Ặ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'È': 'E',
      'É': 'E',
      'Ẹ': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ê': 'E',
      'Ề': 'E',
      'Ế': 'E',
      'Ệ': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Ị': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ọ': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ô': 'O',
      'Ồ': 'O',
      'Ố': 'O',
      'Ộ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ơ': 'O',
      'Ờ': 'O',
      'Ớ': 'O',
      'Ợ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Ụ': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ư': 'U',
      'Ừ': 'U',
      'Ứ': 'U',
      'Ự': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ỳ': 'Y',
      'Ý': 'Y',
      'Ỵ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Đ': 'D',
    };

    final buffer = StringBuffer();
    for (final codePoint in value.runes) {
      final char = String.fromCharCode(codePoint);
      final replacement = replacements[char];
      if (replacement != null) {
        buffer.write(replacement);
      } else if (codePoint >= 32 && codePoint <= 126) {
        buffer.write(char);
      } else {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }
}

class _PdfTextLine {
  const _PdfTextLine(this.text, this.fontSize, this.x, this.y);

  final String text;
  final num fontSize;
  final num x;
  final num y;
}
