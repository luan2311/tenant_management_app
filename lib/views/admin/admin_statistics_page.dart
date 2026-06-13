import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';

class AdminStatisticsPage extends StatelessWidget {
  const AdminStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final revenue = appState.monthlyRevenue;
    final debtors = appState.debtorList;
    final summary = appState.revenueSummary;

    return RefreshIndicator(
      color: AppColors.sanctuaryDark,
      onRefresh: appState.refreshAllData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
        children: [
          SanctuaryHeader(
            title: 'Thống kê',
            subtitle: 'Doanh thu thực nhận và hóa đơn chưa thanh toán tháng ${appState.currentBillingMonth}.',
            trailing: SoftIconButton(
              icon: Icons.cloud_off_outlined,
              onPressed: appState.runOfflineHealthCheck,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.payments_outlined,
                  label: 'Đã thu tháng này',
                  value: _formatMoney(summary['paid'] ?? 0.0),
                  color: AppColors.badgeEmptyText,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'Còn nợ',
                  value: _formatMoney(summary['unpaid'] ?? 0.0),
                  color: AppColors.badgeMaintenanceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _RevenueChart(monthlyRevenue: revenue),
          const SizedBox(height: 24),
          if (appState.offlineHealthCheck != null) ...[
            _OfflineScanCard(result: appState.offlineHealthCheck!),
            const SizedBox(height: 24),
          ],
          Text(
            'Khách nợ tháng hiện tại',
            style: AppStyles.title(
              context,
              color: AppColors.sanctuaryInk,
              fontWeight: FontWeight.w900,
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
                      'Không có hóa đơn chưa thanh toán trong tháng này.',
                      style: AppStyles.body(context, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            )
          else
            ...debtors.map(
              (debtor) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DebtorTile(debtor: debtor),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      height: 138,
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      opacity: 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 21),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.title(context, color: AppColors.sanctuaryInk, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: AppStyles.caption(context, fontWeight: FontWeight.w800, fontSize: 11)),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final Map<String, double> monthlyRevenue;

  const _RevenueChart({required this.monthlyRevenue});

  @override
  Widget build(BuildContext context) {
    final entries = monthlyRevenue.entries.toList();
    final maxRevenue = entries.fold<double>(0, (max, entry) => entry.value > max ? entry.value : max);
    final maxY = maxRevenue <= 0 ? 8.0 : (maxRevenue / 1000000 * 1.25).clamp(6.0, 100.0).toDouble();

    return GlassmorphicContainer(
      height: 286,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      borderRadius: 22,
      opacity: 0.74,
      child: entries.isEmpty
          ? Center(
              child: Text(
                'Chưa có doanh thu đã thanh toán.',
                style: AppStyles.body(context, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
              ),
            )
          : BarChart(
              BarChartData(
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withOpacity(0.72), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text('${value.toInt()}M', style: AppStyles.caption(context, fontSize: 10, fontWeight: FontWeight.w700));
                      },
                    ),
                  ),
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
                          width: 12,
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.sanctuaryDark,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: AppColors.sanctuaryBlue.withOpacity(0.5),
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

class _OfflineScanCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _OfflineScanCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isHealthy = result['isHealthy'] == true;
    final passed = result['passed'] ?? 0;
    final total = result['total'] ?? 0;

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      opacity: 0.78,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isHealthy ? AppColors.badgeEmptyBg : AppColors.badgeMaintenanceBg,
            child: Icon(
              isHealthy ? Icons.offline_bolt_outlined : Icons.error_outline_rounded,
              color: isHealthy ? AppColors.badgeEmptyText : AppColors.badgeMaintenanceText,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy ? 'Offline scan ổn định' : 'Offline scan cần kiểm tra',
                  style: AppStyles.body(context, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text('$passed/$total kiểm tra SQLite đã hoàn tất.', style: AppStyles.caption(context, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtorTile extends StatelessWidget {
  final Map<String, dynamic> debtor;

  const _DebtorTile({required this.debtor});

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
            child: Icon(Icons.person_pin_circle_outlined, color: AppColors.badgeMaintenanceText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${debtor['tenant_name']}', style: AppStyles.body(context, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  'Phòng ${debtor['room_number']} - ${debtor['tenant_phone']}',
                  style: AppStyles.caption(context, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney((debtor['total_price'] as num).toDouble()),
            style: AppStyles.caption(context, color: AppColors.badgeMaintenanceText, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(double amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
  }

  final value = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final positionFromEnd = value.length - i;
    buffer.write(value[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${buffer}đ';
}
