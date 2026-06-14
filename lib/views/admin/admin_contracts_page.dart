import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/models/contract.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/models/tenant.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';
import 'add_contract_screen.dart';

class AdminContractsPage extends StatefulWidget {
  const AdminContractsPage({super.key});

  @override
  State<AdminContractsPage> createState() => _AdminContractsPageState();
}

class _AdminContractsPageState extends State<AdminContractsPage> {
  // 'all' | 'active' | 'ended'
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final contracts = [...appState.contracts]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final activeCount = contracts
        .where((item) => item.status == 'active')
        .length;
    final endingSoonCount = contracts.where(_isEndingSoon).length;

    final visibleContracts = contracts.where((item) {
      switch (_filter) {
        case 'active':
          return item.status == 'active';
        case 'ended':
          return item.status != 'active';
        default:
          return true;
      }
    }).toList();

    return RefreshIndicator(
      color: AppColors.sanctuaryDark,
      onRefresh: appState.refreshAllData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
        children: [
          SanctuaryHeader(
            title: 'Quản lý hợp đồng',
            subtitle:
                'Theo dõi thời hạn thuê, tiền cọc và trạng thái từng hợp đồng.',
            trailing: SoftIconButton(
              icon: Icons.assignment_add,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddContractScreen()),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  icon: Icons.history_edu_outlined,
                  label: 'Đang hiệu lực',
                  value: '$activeCount',
                  color: AppColors.badgeRentedText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.event_busy_outlined,
                  label: 'Sắp hết hạn',
                  value: '$endingSoonCount',
                  color: AppColors.badgeMaintenanceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FilterBar(
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 18),
          if (visibleContracts.isEmpty)
            GlassmorphicContainer(
              height: 240,
              borderRadius: 22,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 54,
                    color: AppColors.textSecondary.withValues(alpha: 0.72),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    contracts.isEmpty
                        ? 'Chưa có hợp đồng nào.'
                        : 'Không có hợp đồng phù hợp bộ lọc.',
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
            ...visibleContracts.map((contract) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ContractCard(contract: contract),
              );
            }),
        ],
      ),
    );
  }

  static bool _isEndingSoon(ContractModel contract) {
    if (contract.status != 'active') return false;
    final endDate = DateTime.tryParse(contract.endDate);
    if (endDate == null) return false;
    final today = DateTime.now();
    return endDate.isAfter(today) && endDate.difference(today).inDays <= 30;
  }
}

class _ContractCard extends StatelessWidget {
  final ContractModel contract;

  const _ContractCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final room = _firstWhereOrNull<RoomModel>(
      appState.rooms,
      (item) => item.id == contract.roomId,
    );
    final tenant = _firstWhereOrNull<TenantModel>(
      appState.tenants,
      (item) => item.id == contract.tenantId,
    );
    final status = _statusInfo(contract.status);

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
                backgroundColor: AppColors.sanctuaryBlue.withValues(
                  alpha: 0.62,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.sanctuaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phòng ${room?.roomNumber ?? contract.roomId}',
                      style: AppStyles.title(
                        context,
                        color: AppColors.sanctuaryInk,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tenant?.fullName ?? 'Khách thuê #${contract.tenantId}',
                      style: AppStyles.caption(
                        context,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: status.label,
                backgroundColor: status.background,
                textColor: status.foreground,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Thời hạn',
            value: '${contract.startDate} - ${contract.endDate}',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.savings_outlined,
            label: 'Tiền cọc',
            value: _formatMoney(contract.deposit),
          ),
          if (contract.status == 'active') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmTerminate(context, contract),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.badgeMaintenanceText,
                  side: BorderSide(
                    color: AppColors.badgeMaintenanceText.withValues(
                      alpha: 0.34,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white.withValues(alpha: 0.36),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'Kết thúc hợp đồng',
                  style: AppStyles.body(
                    context,
                    color: AppColors.badgeMaintenanceText,
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

  Future<void> _confirmTerminate(
    BuildContext context,
    ContractModel contract,
  ) async {
    if (contract.id == null) return;
    final appState = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Kết thúc hợp đồng?',
            style: AppStyles.title(
              dialogContext,
              color: AppColors.sanctuaryInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Phòng sẽ được chuyển về trạng thái trống sau khi kết thúc hợp đồng này.',
            style: AppStyles.body(
              dialogContext,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Hủy',
                style: AppStyles.body(
                  dialogContext,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.badgeMaintenanceText,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'Xác nhận',
                style: AppStyles.body(
                  dialogContext,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;
    final success = await appState.terminateContract(
      contract.id!,
      contract.roomId,
    );
    if (!context.mounted) return;
    final detail = appState.lastErrorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã kết thúc hợp đồng.'
              : (detail == null || detail.isEmpty
                    ? 'Không thể kết thúc hợp đồng. Vui lòng thử lại.'
                    : 'Không thể kết thúc hợp đồng: $detail'),
        ),
        duration: success
            ? const Duration(seconds: 4)
            : const Duration(seconds: 6),
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'active':
        return const _StatusInfo(
          'Đang hiệu lực',
          AppColors.badgeRentedBg,
          AppColors.badgeRentedText,
        );
      case 'terminated':
        return const _StatusInfo(
          'Đã kết thúc',
          AppColors.badgeMaintenanceBg,
          AppColors.badgeMaintenanceText,
        );
      default:
        return const _StatusInfo(
          'Hết hạn',
          AppColors.badgeEmptyBg,
          AppColors.badgeEmptyText,
        );
    }
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('all', 'Tất cả'),
      ('active', 'Đang hiệu lực'),
      ('ended', 'Đã kết thúc'),
    ];

    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: _FilterChip(
              label: option.$2,
              isSelected: selected == option.$1,
              onTap: () => onSelected(option.$1),
            ),
          ),
          if (option != options.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sanctuaryDark
                : Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.sanctuaryDark
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.caption(
              context,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      height: 148,
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: AppStyles.headline(
              context,
              color: AppColors.sanctuaryInk,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _StatusInfo {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusInfo(this.label, this.background, this.foreground);
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

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
