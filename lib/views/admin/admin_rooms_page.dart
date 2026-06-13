import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/models/facility.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/styles.dart';
import 'admin_add_room_page.dart';

class AdminRoomsPage extends StatelessWidget {
  const AdminRoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final facilities = appState.facilities;
    final rooms = appState.filteredRooms;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
      children: [
        SanctuaryHeader(
          title: 'Quản lý phòng',
          subtitle: 'Theo dõi phòng trống, đang thuê và bảo trì theo từng cơ sở.',
          trailing: SoftIconButton(
            icon: Icons.add_rounded,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAddRoomPage())),
          ),
        ),
        const SizedBox(height: 22),
        _FacilityFilters(appState: appState, facilities: facilities),
        const SizedBox(height: 12),
        _StatusFilters(appState: appState),
        const SizedBox(height: 22),
        if (rooms.isEmpty)
          GlassmorphicContainer(
            height: 240,
            borderRadius: 22,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.meeting_room_outlined, size: 54, color: AppColors.textSecondary.withOpacity(0.72)),
                const SizedBox(height: 14),
                Text('Không tìm thấy phòng phù hợp.', style: AppStyles.body(context, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 208,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final facility = facilities.firstWhere(
                (f) => f.id == room.facilityId,
                orElse: () => FacilityModel(name: 'Không rõ cơ sở', address: ''),
              );
              return _RoomCard(room: room, facility: facility);
            },
          ),
      ],
    );
  }
}

class _FacilityFilters extends StatelessWidget {
  final AppState appState;
  final List<FacilityModel> facilities;

  const _FacilityFilters({required this.appState, required this.facilities});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả cơ sở',
            selected: appState.selectedFacilityId == null,
            onTap: () => appState.filterRoomsByFacility(null),
          ),
          const SizedBox(width: 8),
          ...facilities.map((facility) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: facility.name.replaceAll('Lumiere Stay - ', ''),
                selected: appState.selectedFacilityId == facility.id,
                onTap: () => appState.filterRoomsByFacility(facility.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final AppState appState;

  const _StatusFilters({required this.appState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'Tất cả', selected: appState.selectedRoomStatus == 'all', onTap: () => appState.filterRoomsByStatus('all')),
          const SizedBox(width: 8),
          _FilterChip(label: 'Trống', selected: appState.selectedRoomStatus == 'empty', onTap: () => appState.filterRoomsByStatus('empty')),
          const SizedBox(width: 8),
          _FilterChip(label: 'Đang thuê', selected: appState.selectedRoomStatus == 'rented', onTap: () => appState.filterRoomsByStatus('rented')),
          const SizedBox(width: 8),
          _FilterChip(label: 'Bảo trì', selected: appState.selectedRoomStatus == 'maintenance', onTap: () => appState.filterRoomsByStatus('maintenance')),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.visible,
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.sanctuaryDark,
      backgroundColor: Colors.white.withOpacity(0.52),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      labelStyle: AppStyles.caption(
        context,
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: 11,
      ).copyWith(height: 1.25),
      side: BorderSide(color: Colors.white.withOpacity(0.72)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final FacilityModel facility;

  const _RoomCard({required this.room, required this.facility});

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(room.status);

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      opacity: 0.72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(label: status.label, backgroundColor: status.background, textColor: status.foreground),
              const Spacer(),
              Builder(
                builder: (buttonContext) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _showRoomActions(buttonContext, context, room),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.46),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.more_horiz_rounded, color: AppColors.sanctuaryDark, size: 22),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Phòng ${room.roomNumber}',
            style: AppStyles.title(context, color: AppColors.sanctuaryInk, fontWeight: FontWeight.w900, fontSize: 17),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            facility.name.replaceAll('Lumiere Stay - ', ''),
            style: AppStyles.caption(context, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text('Giá thuê', style: AppStyles.caption(context, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            _formatMoney(room.price),
            style: AppStyles.body(context, color: AppColors.sanctuaryInk, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Cọc ${_formatMoney(room.deposit)} - ${room.maxTenants} người',
            style: AppStyles.caption(context, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'empty':
        return const _StatusInfo('Trống', AppColors.badgeEmptyBg, AppColors.badgeEmptyText);
      case 'rented':
        return const _StatusInfo('Đang thuê', AppColors.badgeRentedBg, AppColors.badgeRentedText);
      default:
        return const _StatusInfo('Bảo trì', AppColors.badgeMaintenanceBg, AppColors.badgeMaintenanceText);
    }
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

    return '${buffer}đ';
  }

  Future<void> _confirmDeleteRoom(BuildContext context, RoomModel room) async {
    final appState = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Xóa phòng ${room.roomNumber}?',
            style: AppStyles.title(dialogContext, color: AppColors.sanctuaryInk, fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Thao tác này sẽ xóa phòng và các dữ liệu hợp đồng, hóa đơn liên quan đến phòng này.',
            style: AppStyles.body(dialogContext, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Hủy', style: AppStyles.body(dialogContext, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.badgeMaintenanceText,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text('Xóa', style: AppStyles.body(dialogContext, color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted || room.id == null) return;

    final success = await appState.deleteRoom(room.id!);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Đã xóa phòng ${room.roomNumber}.' : 'Xóa phòng thất bại. Vui lòng thử lại.')),
    );
  }

  Future<void> _showRoomActions(BuildContext anchorContext, BuildContext pageContext, RoomModel room) async {
    final button = anchorContext.findRenderObject() as RenderBox;
    final overlay = Navigator.of(pageContext).overlay!.context.findRenderObject() as RenderBox;
    final buttonRect = Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
    );

    final action = await showMenu<_RoomAction>(
      context: pageContext,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromRect(buttonRect, Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          value: _RoomAction.edit,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, color: AppColors.sanctuaryDark, size: 19),
              const SizedBox(width: 10),
              Text('Cập nhật', style: AppStyles.body(pageContext, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _RoomAction.delete,
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, color: AppColors.badgeMaintenanceText, size: 19),
              const SizedBox(width: 10),
              Text(
                'Xóa phòng',
                style: AppStyles.body(pageContext, color: AppColors.badgeMaintenanceText, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );

    if (action == null || !pageContext.mounted) return;

    switch (action) {
      case _RoomAction.edit:
        Navigator.of(pageContext).push(
          MaterialPageRoute(builder: (_) => AdminAddRoomPage(room: room)),
        );
        break;
      case _RoomAction.delete:
        _confirmDeleteRoom(pageContext, room);
        break;
    }
  }
}

enum _RoomAction { edit, delete }

class _StatusInfo {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusInfo(this.label, this.background, this.foreground);
}
