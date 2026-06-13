import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';
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
            right: -10,
            top: -10,
            child: Icon(Icons.monetization_on_outlined, size: 72, color: AppColors.sanctuaryBlue.withOpacity(0.75)),
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
