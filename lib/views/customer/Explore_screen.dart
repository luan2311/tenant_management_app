import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/mock/room_mock_data.dart';
import 'package:tenant_management_app/models/facility.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'room_detail_screen.dart';

// ─── ExploreScreen — Khám phá phòng trống ────────────────────────────────────
// HUY.3.2 · Sprint 3
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedFilter = 0;

  static const _filters = ['Tất cả', 'Dưới 3tr', '3 – 5tr', 'Trên 5tr'];
  static const _filterIcons = [
    Icons.tune_rounded,
    Icons.arrow_downward_rounded,
    Icons.attach_money_rounded,
    Icons.arrow_upward_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dbRooms = appState.rooms;

    // Chuyển đổi dữ liệu từ SQLite RoomModel sang RoomData để hiển thị ở trang Khám phá
    final roomsData = dbRooms.map((room) {
      final facility = appState.facilities.firstWhere(
        (f) => f.id == room.facilityId,
        orElse: () => FacilityModel(name: 'Không rõ cơ sở', address: ''),
      );

      return RoomData(
        id: room.id ?? 0,
        roomNumber: room.roomNumber,
        facility: facility.name.replaceAll('Lumiere Stay - ', ''),
        price: room.price,
        deposit: room.deposit,
        maxTenants: room.maxTenants,
        status: room.status,
        amenities: room.amenities,
        description: room.description,
        imageUrl: room.imageUrl,
      );
    }).toList();

    final empty = roomsData.where((r) => r.status == 'empty').toList();

    List<RoomData> rooms;
    switch (_selectedFilter) {
      case 1:
        rooms = empty.where((r) => r.price < 3000000).toList();
        break;
      case 2:
        rooms = empty
            .where((r) => r.price >= 3000000 && r.price <= 5000000)
            .toList();
        break;
      case 3:
        rooms = empty.where((r) => r.price > 5000000).toList();
        break;
      default:
        rooms = empty;
    }
    return Scaffold(
      backgroundColor: kSurface,
      body: Stack(
        children: [
          const _AmbientBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _SearchBar(),
                    const SizedBox(height: 12),
                    _FilterChips(
                      selected: _selectedFilter,
                      filters: _filters,
                      icons: _filterIcons,
                      onSelected: (i) => setState(() => _selectedFilter = i),
                    ),
                    const SizedBox(height: 24),
                    _RoomListHeader(count: rooms.length),
                    const SizedBox(height: 16),
                    if (rooms.isEmpty)
                      _EmptyState()
                    else
                      ...List.generate(
                        rooms.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _RoomCard(
                            room: rooms[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      RoomDetailScreen(room: rooms[i])),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.bubble_chart_rounded, color: kPrimary, size: 26),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryFixed, kPrimary],
            ).createShader(bounds),
            child: const Text(
              'Lumiere Stay',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient Background ───────────────────────────────────────────────────────
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -size.height * 0.1,
              left: -size.width * 0.1,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryFixed.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.1,
              right: -size.width * 0.1,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kSecondaryContainer.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: kOutlineVariant.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.7),
                blurRadius: 8,
                offset: const Offset(-4, -4),
              ),
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: kOnSurfaceVariant, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm phòng, khu vực...',
                    hintStyle: TextStyle(
                      color: kOutlineVariant,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(color: kOnSurface, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.filters,
    required this.icons,
    required this.onSelected,
  });

  final int               selected;
  final List<String>      filters;
  final List<IconData>    icons;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? kPrimaryFixed
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : kOutlineVariant.withValues(alpha: 0.15),
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: kPrimaryFixed.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[i],
                      size: 16,
                      color: active ? kOnPrimaryFixed : kOnSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filters[i],
                      style: TextStyle(
                        color: active ? kOnPrimaryFixed : kOnSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Room List Header ─────────────────────────────────────────────────────────
class _RoomListHeader extends StatelessWidget {
  final int count;
  const _RoomListHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phòng trống',
                style: TextStyle(
                  color: kOnSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tìm thấy $count phòng phù hợp',
                style: const TextStyle(
                  color: kOnSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 52, color: kOutline.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Không có phòng phù hợp',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử chọn bộ lọc khác',
              style: TextStyle(fontSize: 13, color: kOnSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Room Card ────────────────────────────────────────────────────────────────
class _RoomCard extends StatefulWidget {
  final RoomData     room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  State<_RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<_RoomCard> {
  bool _pressed = false;

  String _formatPrice(double p) {
    final m = p / 1000000;
    return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: kOutlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image area ──────────────────────────────────────────
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: AnimatedScale(
                        scale: _pressed ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: room.imageUrl != null
                            ? Image.network(
                                room.imageUrl!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, trace) =>
                                    _imageFallback(room),
                              )
                            : _imageFallback(room),
                      ),
                    ),
                    // Badge "Còn trống"
                    Positioned(
                      top: 14, left: 14,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: kPrimaryFixed,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Còn trống',
                              style: TextStyle(
                                color: kOnPrimaryFixed,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Info area ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phòng ${room.roomNumber}',
                                  style: const TextStyle(
                                    color: kOnSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 13, color: kOnSurfaceVariant),
                                    const SizedBox(width: 3),
                                    Text(
                                      room.facility,
                                      style: const TextStyle(
                                        color: kOnSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_formatPrice(room.price)}đ',
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                '/tháng',
                                style: TextStyle(
                                  color: kOutline,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: kOutlineVariant.withValues(alpha: 0.2),
                          height: 1,
                        ),
                      ),

                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.person_outline_rounded,
                            label: 'Tối đa ${room.maxTenants} người',
                          ),
                          const SizedBox(width: 16),
                          _MetaChip(
                            icon: Icons.payments_outlined,
                            label: 'Cọc ${_formatPrice(room.deposit)}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      _DetailButton(onTap: widget.onTap),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback(RoomData room) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryFixed, kPrimary],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.house_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 6),
          Text(
            'Phòng ${room.roomNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Meta Chip ────────────────────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: kOnSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: kOnSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Detail Button ────────────────────────────────────────────────────────────
class _DetailButton extends StatefulWidget {
  const _DetailButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DetailButton> createState() => _DetailButtonState();
}

class _DetailButtonState extends State<_DetailButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _pressed ? kSurfaceContainerHigh : kSurfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 16,
              offset: const Offset(-4, -4),
            ),
            BoxShadow(
              color: kOnSurfaceVariant.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Xem chi tiết',
              style: TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, color: kPrimary, size: 17),
          ],
        ),
      ),
    );
  }
}
