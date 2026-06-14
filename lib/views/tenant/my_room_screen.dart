import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'my_invoice_screen.dart';
import 'contract_detail_screen.dart';
import 'contract_history_screen.dart';

class MyRoomScreen extends StatelessWidget {
  const MyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeData = appState.activeRoomData;

    // Check if the tenant doesn't have an active room
    if (activeData == null ||
        activeData['room'] == null ||
        activeData['contract'] == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.meeting_room_outlined,
                    size: 80,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa thuê phòng nào',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy chọn phòng phù hợp ở trang Khám phá và gửi yêu cầu thuê phòng cho chủ trọ nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  if (appState.contractHistory.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContractHistoryScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text(
                        'Xem lịch sử hợp đồng',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E6486),
                        side: const BorderSide(color: Color(0xFF2E6486)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    final room = activeData['room'];
    final tenant = activeData['tenant'];
    final List<dynamic> roommates = activeData['roommates'] as List<dynamic>;

    final roomNumber = room['room_number'] as String? ?? '';
    final roomPrice = (room['price'] as num).toDouble();
    final maxTenants = room['max_tenants'] as int? ?? 2;
    final emptySlotCount = (maxTenants - 1 - roommates.length)
        .clamp(0, maxTenants)
        .toInt();

    final priceStr =
        '${roomPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

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
                    Text(
                      'Phòng của tôi',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Thông tin chi tiết và bạn cùng phòng',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Thẻ thông tin phòng chính (Glassmorphic Card)
              _buildMainRoomCard(roomNumber, priceStr),
              const SizedBox(height: 16),

              // Thẻ hiển thị đơn giá Tiện ích
              _buildUtilitiesCard(),
              const SizedBox(height: 16),

              // Nút điều hướng nhanh
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyInvoiceScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: const Text(
                        'Hóa đơn',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E6486),
                        side: const BorderSide(color: Color(0xFF2E6486)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContractDetailScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.assignment_outlined, size: 18),
                      label: const Text(
                        'Hợp đồng',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E6486),
                        side: const BorderSide(color: Color(0xFF2E6486)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Khu vực Người ở chung
              const Text(
                'Người ở chung',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    // Đại diện phòng (Chính là tài khoản đăng nhập)
                    _buildRoommateRow(
                      context,
                      tenant['full_name'] as String,
                      'Đại diện phòng (Bạn)',
                      true,
                      cccd: tenant['cccd'] as String?,
                      appState: appState,
                    ),

                    // Thành viên phòng
                    ...roommates.map(
                      (rm) => _buildRoommateRow(
                        context,
                        rm['full_name'] as String,
                        'Thành viên',
                        false,
                        cccd: rm['cccd'] as String?,
                        appState: appState,
                      ),
                    ),

                    // Các slot trống còn lại
                    for (int i = 0; i < emptySlotCount; i++)
                      _buildEmptySlotRow(context, appState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRoommateDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final cccdController = TextEditingController();
    final hometownController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Thêm người ở cùng',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      labelStyle: TextStyle(fontFamily: 'Be Vietnam Pro'),
                    ),
                    style: const TextStyle(fontFamily: 'Be Vietnam Pro'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      labelStyle: TextStyle(fontFamily: 'Be Vietnam Pro'),
                    ),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontFamily: 'Be Vietnam Pro'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Vui lòng nhập số điện thoại'
                        : null,
                  ),
                  TextFormField(
                    controller: cccdController,
                    decoration: const InputDecoration(
                      labelText: 'Số CCCD',
                      labelStyle: TextStyle(fontFamily: 'Be Vietnam Pro'),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Be Vietnam Pro'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Vui lòng nhập số CCCD'
                        : null,
                  ),
                  TextFormField(
                    controller: hometownController,
                    decoration: const InputDecoration(
                      labelText: 'Quê quán',
                      labelStyle: TextStyle(fontFamily: 'Be Vietnam Pro'),
                    ),
                    style: const TextStyle(fontFamily: 'Be Vietnam Pro'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Vui lòng nhập quê quán'
                        : null,
                  ),
                ],
              ),
            ),
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
                backgroundColor: const Color(0xFF2E6486),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  final success = await appState.addRoommate(
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    cccd: cccdController.text.trim(),
                    hometown: hometownController.text.trim(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Thêm người ở cùng thành công!'
                              : 'Thêm người ở cùng thất bại.',
                        ),
                        backgroundColor: success
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Thêm',
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

  void _showRemoveRoommateDialog(
    BuildContext context,
    AppState appState,
    String name,
    String cccd,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Xóa người ở cùng',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa thành viên $name ra khỏi phòng?',
            style: const TextStyle(fontFamily: 'Be Vietnam Pro'),
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
                final success = await appState.removeRoommate(cccd);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Đã xóa thành viên thành công.'
                            : 'Lỗi khi xóa thành viên. Vui lòng thử lại.',
                      ),
                      backgroundColor: success
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text(
                'Xóa',
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

  Widget _buildMainRoomCard(String roomNumber, String priceStr) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SỐ PHÒNG',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                Text(
                  'Phòng $roomNumber',
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giá thuê / tháng: $priceStr',
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBAE6FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Đang thuê',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 11,
                      color: Color(0xFF0369A1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ngày thanh toán',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                const Text(
                  'Mùng 5 hàng tháng',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilitiesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          UtilityRow(
            icon: Icons.electric_bolt,
            label: 'Điện',
            value: '3.500đ / kWh',
          ),
          Divider(color: Colors.white),
          UtilityRow(
            icon: Icons.water_drop,
            label: 'Nước',
            value: '20.000đ / m³',
          ),
          Divider(color: Colors.white),
          UtilityRow(icon: Icons.wifi, label: 'Internet', value: 'Miễn phí'),
        ],
      ),
    );
  }

  Widget _buildRoommateRow(
    BuildContext context,
    String name,
    String role,
    bool isLeader, {
    String? cccd,
    AppState? appState,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isLeader
                ? const Color(0xFFE0F2FE)
                : const Color(0xFFF1F5F9),
            child: Icon(
              Icons.person,
              color: isLeader
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 11,
                    color: isLeader ? const Color(0xFF0284C7) : Colors.black45,
                    fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (!isLeader && cccd != null && appState != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () =>
                  _showRemoveRoommateDialog(context, appState, name, cccd),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotRow(BuildContext context, AppState appState) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showAddRoommateDialog(context, appState),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.person_add_outlined, color: Colors.black26),
            ),
            SizedBox(width: 12),
            Text(
              'Slot còn trống (Click để thêm)',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                color: Colors.black38,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UtilityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UtilityRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2E6486)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
