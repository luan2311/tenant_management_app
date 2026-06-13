import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/models/invoice.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';
import 'create_invoice_screen.dart';

class InvoiceAdminScreen extends StatelessWidget {
  const InvoiceAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EtherealBackground(
        child: SafeArea(
          bottom: false,
          child: AdminInvoicesPage(showBackButton: true),
        ),
      ),
    );
  }
}

class AdminInvoicesPage extends StatefulWidget {
  final bool showBackButton;

  const AdminInvoicesPage({super.key, this.showBackButton = false});

  @override
  State<AdminInvoicesPage> createState() => _AdminInvoicesPageState();
}

class _AdminInvoicesPageState extends State<AdminInvoicesPage> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final invoices = [...appState.invoices]
      ..sort((a, b) => b.billingMonth.compareTo(a.billingMonth));
    final filteredInvoices = invoices.where((item) {
      return _statusFilter == 'all' || item.status == _statusFilter;
    }).toList();
    final paidTotal = invoices
        .where((item) => item.status == 'paid')
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
    final unpaidTotal = invoices
        .where((item) => item.status != 'paid')
        .fold<double>(0, (sum, item) => sum + item.totalPrice);

    return RefreshIndicator(
      color: AppColors.sanctuaryDark,
      onRefresh: appState.refreshAllData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
        children: [
          SanctuaryHeader(
            title: 'Quản lý hóa đơn',
            subtitle:
                'Theo dõi công nợ, doanh thu đã thu và trạng thái thanh toán.',
            trailing: widget.showBackButton
                ? SoftIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.maybePop(context),
                  )
                : GlassmorphicContainer(
                    width: 78,
                    height: 44,
                    borderRadius: 18,
                    opacity: 0.74,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 17,
                          color: AppColors.sanctuaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${filteredInvoices.length}',
                          style: AppStyles.body(
                            context,
                            color: AppColors.sanctuaryDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MoneySummaryTile(
                  icon: Icons.payments_outlined,
                  label: 'Đã thu',
                  amount: paidTotal,
                  color: AppColors.badgeEmptyText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MoneySummaryTile(
                  icon: Icons.pending_actions_outlined,
                  label: 'Chưa thu',
                  amount: unpaidTotal,
                  color: AppColors.badgeMaintenanceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sanctuaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.add_card_outlined, size: 19),
              label: Text(
                'Tạo hóa đơn',
                style: AppStyles.body(
                  context,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  selected: _statusFilter == 'all',
                  onTap: () => setState(() => _statusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Chưa thanh toán',
                  selected: _statusFilter == 'unpaid',
                  onTap: () => setState(() => _statusFilter = 'unpaid'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Đã thanh toán',
                  selected: _statusFilter == 'paid',
                  onTap: () => setState(() => _statusFilter = 'paid'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (filteredInvoices.isEmpty)
            GlassmorphicContainer(
              height: 240,
              borderRadius: 22,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 54,
                    color: AppColors.textSecondary.withValues(alpha: 0.72),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Không có hóa đơn phù hợp.',
                    style: AppStyles.body(
                      context,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredInvoices.map((invoice) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _InvoiceCard(invoice: invoice),
              );
            }),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final room = _firstWhereOrNull(
      appState.rooms,
      (item) => item.id == invoice.roomId,
    );
    final contract = _firstWhereOrNull(
      appState.contracts,
      (item) => item.id == invoice.contractId,
    );
    final tenant = contract == null
        ? null
        : _firstWhereOrNull(
            appState.tenants,
            (item) => item.id == contract.tenantId,
          );
    final isPaid = invoice.status == 'paid';

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      opacity: 0.74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    (isPaid
                            ? AppColors.badgeEmptyBg
                            : AppColors.badgeMaintenanceBg)
                        .withValues(alpha: 0.9),
                child: Icon(
                  isPaid
                      ? Icons.check_circle_outline_rounded
                      : Icons.receipt_long_outlined,
                  color: isPaid
                      ? AppColors.badgeEmptyText
                      : AppColors.badgeMaintenanceText,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phòng ${room?.roomNumber ?? invoice.roomId}',
                      style: AppStyles.title(
                        context,
                        color: AppColors.sanctuaryInk,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tenant?.fullName ?? 'Khách thuê'} - ${invoice.billingMonth}',
                      style: AppStyles.caption(
                        context,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
                backgroundColor: isPaid
                    ? AppColors.badgeEmptyBg
                    : AppColors.badgeMaintenanceBg,
                textColor: isPaid
                    ? AppColors.badgeEmptyText
                    : AppColors.badgeMaintenanceText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.bolt_outlined,
            label: 'Điện',
            value:
                '${_formatNumber(invoice.newElectricity - invoice.oldElectricity)} kWh',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.water_drop_outlined,
            label: 'Nước',
            value: '${_formatNumber(invoice.newWater - invoice.oldWater)} m³',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Tổng tiền',
            value: _formatMoney(invoice.totalPrice),
          ),
          if (!isPaid && invoice.id != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markPaid(context, invoice.id!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sanctuaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.price_check_rounded, size: 18),
                label: Text(
                  'Đánh dấu đã thanh toán',
                  style: AppStyles.body(
                    context,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _markPaid(BuildContext context, int invoiceId) async {
    final success = await context.read<AppState>().markInvoicePaid(invoiceId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật trạng thái thanh toán.'
              : 'Cập nhật hóa đơn thất bại.',
        ),
      ),
    );
  }
}

class _MoneySummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _MoneySummaryTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      height: 126,
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      opacity: 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            _formatCompactMoney(amount),
            style: AppStyles.headline(
              context,
              color: AppColors.sanctuaryInk,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: AppStyles.caption(
              context,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, maxLines: 1),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.sanctuaryDark,
      backgroundColor: Colors.white.withValues(alpha: 0.52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelStyle: AppStyles.caption(
        context,
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: 11,
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.72)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.sanctuaryDark.withValues(alpha: 0.66),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: AppStyles.caption(context, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppStyles.body(
              context,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

String _formatCompactMoney(double amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
  }
  return _formatMoney(amount);
}

String _formatMoney(double amount) {
  final value = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final positionFromEnd = value.length - i;
    buffer.write(value[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return '$bufferđ';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
