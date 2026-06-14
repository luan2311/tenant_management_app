import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/services/database_helper.dart';
import 'package:tenant_management_app/theme/styles.dart';
import 'package:tenant_management_app/models/rental_request.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/models/notification.dart';
import 'admin_add_room_page.dart';
import 'add_contract_screen.dart';
import 'invoice_admin_screen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedRevenueMonths = 6;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stats = appState.roomStats;
    final user = appState.currentUser;
    final debtors = appState.debtorList;
    final paidRevenue = appState.monthlyRevenue.values.fold<double>(0, (sum, value) => sum + value);

    return RefreshIndicator(
      color: AppColors.sanctuaryDark,
      onRefresh: appState.refreshAllData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
        children: [
          SanctuaryHeader(
            title: 'Ethereal Sanctuary',
            subtitle: 'Xin chào ${user?.fullName ?? 'Luân'}, hôm nay bạn có ${appState.notifications.where((n) => n.isRead == 0).length} thông báo mới.',
            trailing: _NotificationButton(appState: appState),
          ),
          const SizedBox(height: 28),
          _RevenueCard(revenue: paidRevenue, unpaidCount: appState.unpaidInvoicesCount),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.door_front_door_outlined,
                  label: 'PHÒNG TRỐNG',
                  value: '${stats['empty'] ?? 0}',
                  color: AppColors.badgeEmptyText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.people_alt_outlined,
                  label: 'ĐANG THUÊ',
                  value: '${stats['rented'] ?? 0}',
                  color: AppColors.badgeRentedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'THAO TÁC NHANH',
            style: AppStyles.caption(
              context,
              color: AppColors.sanctuaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(
                icon: Icons.add_home_outlined,
                label: 'Thêm phòng',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAddRoomPage())),
              ),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.assignment_add, label: 'Hợp đồng', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddContractScreen()))),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.receipt_long_outlined, label: 'Hóa đơn', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvoiceAdminScreen()))),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BIỂU ĐỒ DOANH THU',
                style: AppStyles.caption(
                  context,
                  color: AppColors.sanctuaryDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              _RevenueRangeSelector(
                selectedMonths: _selectedRevenueMonths,
                onChanged: (value) => setState(() => _selectedRevenueMonths = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RevenueChart(
            monthlyRevenue: appState.monthlyRevenue,
            selectedMonths: _selectedRevenueMonths,
          ),
          _buildRentalRequestsSection(context, appState),
          const SizedBox(height: 28),
          Text(
            'CẦN XỬ LÝ',
            style: AppStyles.caption(
              context,
              color: AppColors.sanctuaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          if (debtors.isEmpty)
            GlassmorphicContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 18,
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.badgeEmptyBg,
                    child: Icon(Icons.check_rounded, color: AppColors.badgeEmptyText),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Không có hóa đơn trễ hạn trong tháng này.',
                      style: AppStyles.body(context, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          else
            ...debtors.take(3).map((debtor) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AttentionTile(debtor: debtor),
                )),
        ],
      ),
    );
  }
}

class _RevenueRangeSelector extends StatelessWidget {
  final int selectedMonths;
  final ValueChanged<int> onChanged;

  const _RevenueRangeSelector({
    required this.selectedMonths,
    required this.onChanged,
  });

  static const List<int> _monthOptions = [1, 3, 6, 12];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: selectedMonths,
      tooltip: 'Chọn mốc thống kê',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final months in _monthOptions)
          PopupMenuItem<int>(
            value: months,
            child: Text('$months tháng', style: AppStyles.body(context, fontWeight: FontWeight.w700)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.70),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.82)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$selectedMonths tháng',
              style: AppStyles.caption(context, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.sanctuaryDark),
          ],
        ),
      ),
    );
  }
}


class _NotificationButton extends StatelessWidget {
  final AppState appState;

  const _NotificationButton({required this.appState});

  @override
  Widget build(BuildContext context) {
    final hasUnread = appState.notifications.any((n) => n.isRead == 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SoftIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () => _showNotifications(context, appState),
        ),
        if (hasUnread)
          Positioned(
            top: 8,
            right: 9,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.badgeMaintenanceText,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotifications(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassmorphicContainer(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          borderRadius: 26,
          opacity: 0.94,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông báo mới', style: AppStyles.title(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: appState.notifications.isEmpty
                        ? Center(child: Text('Không có thông báo mới', style: AppStyles.body(context)))
                        : ListView.separated(
                            itemCount: appState.notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = appState.notifications[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  if (item.isRead == 0) {
                                    appState.readNotification(item.id!);
                                  }
                                  _handleRequestNotification(context, appState, item);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: item.isRead == 0 ? AppColors.sanctuaryBlue.withOpacity(0.45) : Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, style: AppStyles.body(context, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text(item.content, style: AppStyles.caption(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleRequestNotification(BuildContext context, AppState appState, NotificationModel item) {
    if (item.title == 'Yêu cầu gia hạn hợp đồng') {
      final match = RegExp(r'Mã hợp đồng: (\d+), Số tháng: (\d+)').firstMatch(item.content);
      if (match != null) {
        final contractId = int.parse(match.group(1)!);
        final months = int.parse(match.group(2)!);
        
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Duyệt yêu cầu gia hạn', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold)),
              content: Text('Bạn có chắc chắn muốn duyệt gia hạn hợp đồng thêm $months tháng cho yêu cầu này?\n\nChi tiết: ${item.content}', style: const TextStyle(fontFamily: 'Be Vietnam Pro')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.sanctuaryDark),
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close notifications sheet
                    
                    final success = await appState.approveContractExtension(contractId, months);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Đã duyệt yêu cầu gia hạn hợp đồng thành công!' : 'Duyệt gia hạn hợp đồng thất bại. Vui lòng thử lại.'),
                          backgroundColor: success ? Colors.green : Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text('Duyệt', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    } else if (item.title == 'Yêu cầu ngưng hợp đồng') {
      final match = RegExp(r'Mã hợp đồng: (\d+)').firstMatch(item.content);
      if (match != null) {
        final contractId = int.parse(match.group(1)!);
        
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Duyệt yêu cầu ngưng hợp đồng', style: TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold, color: Colors.redAccent)),
              content: Text('Bạn có chắc chắn muốn duyệt yêu cầu kết thúc (ngưng) hợp đồng này? Phòng sẽ được đưa về trạng thái trống.\n\nChi tiết: ${item.content}', style: const TextStyle(fontFamily: 'Be Vietnam Pro')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close notifications sheet
                    
                    final contract = await DatabaseHelper.instance.getContractById(contractId);
                    if (contract == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy hợp đồng tương ứng.'), backgroundColor: Colors.redAccent),
                        );
                      }
                      return;
                    }
                    
                    final success = await appState.terminateContract(contractId, contract.roomId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Đã duyệt yêu cầu kết thúc hợp đồng thành công!' : 'Lỗi khi kết thúc hợp đồng. Vui lòng thử lại.'),
                          backgroundColor: success ? Colors.green : Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text('Duyệt', style: TextStyle(fontFamily: 'Be Vietnam Pro', color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

class _RevenueCard extends StatelessWidget {
  final double revenue;
  final int unpaidCount;

  const _RevenueCard({required this.revenue, required this.unpaidCount});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 22,
      opacity: 0.72,
      child: Stack(
        children: [
          Positioned(
            right: 4,
            top: 4,
            child: Icon(Icons.monetization_on_outlined, size: 64, color: AppColors.sanctuaryBlue.withOpacity(0.75)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DOANH THU ĐÃ THU', style: AppStyles.caption(context, fontWeight: FontWeight.w900, fontSize: 11)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCompactMoney(revenue),
                    style: AppStyles.headline(context, color: AppColors.sanctuaryInk, fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text('VNĐ', style: AppStyles.caption(context, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StatusPill(
                label: unpaidCount == 0 ? 'Tất cả hóa đơn đã ổn' : '$unpaidCount hóa đơn cần xử lý',
                backgroundColor: unpaidCount == 0 ? AppColors.badgeEmptyBg : AppColors.badgeMaintenanceBg,
                textColor: unpaidCount == 0 ? AppColors.badgeEmptyText : AppColors.badgeMaintenanceText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      height: 156,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 20,
      opacity: 0.70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppStyles.headline(context, color: AppColors.sanctuaryInk, fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: AppStyles.caption(context, fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicContainer(
        height: 104,
        borderRadius: 18,
        opacity: 0.66,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.70),
                child: Icon(icon, color: AppColors.sanctuaryDark, size: 21),
              ),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: AppStyles.caption(context, fontWeight: FontWeight.w900, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final Map<String, double> monthlyRevenue;
  final int selectedMonths;

  const _RevenueChart({
    required this.monthlyRevenue,
    required this.selectedMonths,
  });

  @override
  Widget build(BuildContext context) {
    final allEntries = monthlyRevenue.entries.toList();
    final entries = allEntries.length <= selectedMonths
        ? allEntries
        : allEntries.skip(allEntries.length - selectedMonths).toList();

    return GlassmorphicContainer(
      height: 256,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      borderRadius: 22,
      opacity: 0.72,
      child: entries.isEmpty
          ? Center(child: Text('Chưa có doanh thu đã thanh toán.', style: AppStyles.body(context, color: AppColors.textSecondary)))
          : BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withOpacity(0.72), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                        final month = entries[index].key.substring(5);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('T$month', style: AppStyles.caption(context, fontSize: 10, fontWeight: FontWeight.w800)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < entries.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: entries[i].value / 1000000,
                          width: 8,
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.sanctuaryDark,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 8,
                            color: AppColors.sanctuaryBlue.withOpacity(0.50),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final Map<String, dynamic> debtor;

  const _AttentionTile({required this.debtor});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      opacity: 0.74,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.badgeMaintenanceBg,
            child: Icon(Icons.receipt_long_outlined, color: AppColors.badgeMaintenanceText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phòng ${debtor['room_number']} - Nợ tiền', style: AppStyles.body(context, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text('${debtor['tenant_name']} - ${debtor['billing_month']}', style: AppStyles.caption(context)),
              ],
            ),
          ),
          Text('${_formatCompactMoney((debtor['total_price'] as num).toDouble())}', style: AppStyles.caption(context, color: AppColors.badgeMaintenanceText, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

String _formatCompactMoney(double amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
  }
  return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{3})(?=\d)'), (m) => '${m[1]}.');
}

Widget _buildRentalRequestsSection(BuildContext context, AppState appState) {
  final pending = appState.pendingRequests;
  if (pending.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 28),
      Text(
        'YÊU CẦU THUÊ PHÒNG CHỜ DUYỆT',
        style: AppStyles.caption(
          context,
          color: AppColors.sanctuaryDark,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 12),
      ...pending.map((request) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RentalRequestTile(request: request),
          )),
    ],
  );
}

class _RentalRequestTile extends StatelessWidget {
  final RentalRequestModel request;

  const _RentalRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      opacity: 0.74,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.sanctuaryBlue.withOpacity(0.45),
            child: const Icon(Icons.assignment_ind_outlined, color: AppColors.sanctuaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phòng ${request.roomNumber}',
                  style: AppStyles.body(context, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  'Khách: ${request.fullName} (${request.occupants} người)',
                  style: AppStyles.caption(context, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ngày thuê: ${request.startDate}',
                  style: AppStyles.caption(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showApproveRequestDialog(context, request),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sanctuaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Xem & Duyệt',
              style: AppStyles.caption(context, color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveRequestDialog(BuildContext context, RentalRequestModel request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ApproveRequestDialog(request: request),
    );
  }
}

class _ApproveRequestDialog extends StatefulWidget {
  final RentalRequestModel request;

  const _ApproveRequestDialog({required this.request});

  @override
  State<_ApproveRequestDialog> createState() => _ApproveRequestDialogState();
}

class _ApproveRequestDialogState extends State<_ApproveRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _electricityController = TextEditingController(text: '0.0');
  final _waterController = TextEditingController(text: '0.0');
  final _customMonthsController = TextEditingController();

  String _selectedDurationOption = '6'; // default 6 months
  bool _isRejecting = false;
  bool _isApproving = false;

  @override
  void dispose() {
    _electricityController.dispose();
    _waterController.dispose();
    _customMonthsController.dispose();
    super.dispose();
  }

  InputDecoration _dialogInputDecoration(String label, {String? suffixText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppStyles.caption(context, color: AppColors.textSecondary),
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.sanctuaryDark, width: 1.2),
      ),
      errorStyle: const TextStyle(height: 0.8, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final room = appState.rooms.firstWhere(
      (r) => r.id == widget.request.roomId,
      orElse: () => RoomModel(
        id: widget.request.roomId,
        facilityId: 0,
        roomNumber: widget.request.roomNumber,
        price: 0,
        deposit: 0,
        status: 'empty',
      ),
    );
    final roomPrice = room.price;

    final isCustomDuration = _selectedDurationOption == 'custom';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassmorphicContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        opacity: 0.96,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Chi tiết & Duyệt yêu cầu',
                        style: AppStyles.title(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.sanctuaryDark),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),

                // Tenant details
                Text('THÔNG TIN KHÁCH THUÊ', style: AppStyles.caption(context, fontWeight: FontWeight.w900, color: AppColors.sanctuaryDark)),
                const SizedBox(height: 8),
                _buildInfoRow('Họ và tên:', widget.request.fullName),
                _buildInfoRow('Số điện thoại:', widget.request.phone),
                _buildInfoRow('Số CCCD:', widget.request.cccd),
                if (widget.request.hometown != null && widget.request.hometown!.isNotEmpty)
                  _buildInfoRow('Quê quán:', widget.request.hometown!),
                _buildInfoRow('Số người ở:', '${widget.request.occupants} người'),
                _buildInfoRow('Ngày dự kiến thuê:', widget.request.startDate),
                _buildInfoRow('Thuê phòng:', widget.request.roomNumber),
                _buildInfoRow('Giá phòng:', '${roomPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{3})(?=\d)"), (m) => "${m[1]}.")} VNĐ/tháng'),
                _buildRoommatesSection(widget.request.roommates),

                const SizedBox(height: 20),
                Text('CẤU HÌNH HỢP ĐỒNG', style: AppStyles.caption(context, fontWeight: FontWeight.w900, color: AppColors.sanctuaryDark)),
                const SizedBox(height: 12),

                // Lease term dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDurationOption,
                  decoration: _dialogInputDecoration('Thời hạn hợp đồng'),
                  dropdownColor: AppColors.backgroundMiddle,
                  items: const [
                    DropdownMenuItem(value: '3', child: Text('3 tháng')),
                    DropdownMenuItem(value: '6', child: Text('6 tháng')),
                    DropdownMenuItem(value: '12', child: Text('12 tháng')),
                    DropdownMenuItem(value: '24', child: Text('24 tháng')),
                    DropdownMenuItem(value: 'custom', child: Text('Thời hạn khác...')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDurationOption = value;
                      });
                    }
                  },
                ),
                if (isCustomDuration) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customMonthsController,
                    keyboardType: TextInputType.number,
                    decoration: _dialogInputDecoration('Thời hạn tùy chỉnh', suffixText: 'tháng'),
                    validator: (value) {
                      if (!isCustomDuration) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số tháng';
                      }
                      final n = int.tryParse(value);
                      if (n == null || n <= 0) {
                        return 'Số tháng phải là số nguyên dương lớn hơn 0';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _electricityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _dialogInputDecoration('Số điện ban đầu', suffixText: 'kWh'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bắt buộc';
                          }
                          final d = double.tryParse(value);
                          if (d == null || d < 0) {
                            return 'Hợp lệ >= 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _waterController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _dialogInputDecoration('Số nước ban đầu', suffixText: 'm³'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bắt buộc';
                          }
                          final d = double.tryParse(value);
                          if (d == null || d < 0) {
                            return 'Hợp lệ >= 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isRejecting || _isApproving ? null : _handleReject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.badgeMaintenanceText),
                          foregroundColor: AppColors.badgeMaintenanceText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isRejecting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.badgeMaintenanceText))
                            : Text('Từ chối', style: AppStyles.body(context, color: AppColors.badgeMaintenanceText, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRejecting || _isApproving ? null : _handleApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.badgeEmptyText,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isApproving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Duyệt thuê', style: AppStyles.body(context, color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppStyles.caption(context, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: AppStyles.body(context, fontWeight: FontWeight.w700, color: AppColors.sanctuaryInk)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoommatesSection(String? roommatesJson) {
    if (roommatesJson == null || roommatesJson.isEmpty) return const SizedBox();
    try {
      final List<dynamic> list = jsonDecode(roommatesJson);
      if (list.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'THÔNG TIN NGƯỜI Ở CÙNG (${list.length})',
            style: AppStyles.caption(context, fontWeight: FontWeight.w900, color: AppColors.sanctuaryDark),
          ),
          const SizedBox(height: 6),
          ...list.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value as Map<String, dynamic>;
            final name = item['full_name'] ?? '';
            final cccd = item['cccd'] ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Người ở cùng $idx:',
                      style: AppStyles.caption(context, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppStyles.body(context, fontWeight: FontWeight.w700, color: AppColors.sanctuaryInk),
                        ),
                        Text(
                          'CCCD: $cccd',
                          style: AppStyles.caption(context, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Future<void> _handleReject() async {
    setState(() => _isRejecting = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.rejectRentalRequest(widget.request);
    setState(() => _isRejecting = false);

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối yêu cầu thuê phòng.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi từ chối yêu cầu.')),
        );
      }
    }
  }

  Future<void> _handleApprove() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isApproving = true);
    final appState = Provider.of<AppState>(context, listen: false);

    final initialElectricity = double.parse(_electricityController.text);
    final initialWater = double.parse(_waterController.text);
    
    int durationMonths;
    if (_selectedDurationOption == 'custom') {
      durationMonths = int.parse(_customMonthsController.text);
    } else {
      durationMonths = int.parse(_selectedDurationOption);
    }

    final room = appState.rooms.firstWhere(
      (r) => r.id == widget.request.roomId,
      orElse: () => RoomModel(
        id: widget.request.roomId,
        facilityId: 0,
        roomNumber: widget.request.roomNumber,
        price: 0,
        deposit: 0,
        status: 'empty',
      ),
    );

    final success = await appState.approveRentalRequest(
      request: widget.request,
      roomPrice: room.price,
      durationMonths: durationMonths,
      initialElectricity: initialElectricity,
      initialWater: initialWater,
    );

    setState(() => _isApproving = false);

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã duyệt yêu cầu thuê và tạo hợp đồng thành công.')),
        );
      }
    } else {
      if (mounted) {
        final detail = appState.lastErrorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              detail == null || detail.isEmpty
                  ? 'Có lỗi xảy ra khi duyệt yêu cầu.'
                  : 'Có lỗi xảy ra khi duyệt yêu cầu: $detail',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }
}
