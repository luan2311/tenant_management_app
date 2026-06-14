import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/mock/room_mock_data.dart';
import 'rental_request_screen.dart';

// ─── RoomDetailScreen — Chi tiết phòng ───────────────────────────────────────
// HUY.3.3 · Sprint 3  (filename giữ nguyên để tránh thay đổi import)
class RoomDetailScreen extends StatefulWidget {
  final RoomData room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _isFavorite = false;

  // Map tên tiện ích → icon
  static const _amenityIcons = <String, IconData>{
    'Điều hoà':   Icons.ac_unit_rounded,
    'WC riêng':   Icons.bathroom_rounded,
    'Wifi':       Icons.wifi_rounded,
    'Bãi xe':     Icons.two_wheeler_rounded,
    'Tủ lạnh':   Icons.kitchen_rounded,
    'Ban công':   Icons.balcony_rounded,
    'Máy giặt':  Icons.local_laundry_service_rounded,
    'Bếp':        Icons.soup_kitchen_rounded,
  };

  bool get _isAvailable => widget.room.status == 'empty';

  String _formatMillion(double price) {
    final m = price / 1000000;
    return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable body ────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(room: widget.room),
                _InfoGrid(room: widget.room, formatM: _formatMillion),
                const SizedBox(height: 28),
                _DescriptionSection(description: widget.room.description),
                const SizedBox(height: 28),
                _AmenitiesSection(
                  amenities: widget.room.amenities,
                  iconMap: _amenityIcons,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Floating header overlay ────────────────────────────────────
          _FloatingHeader(
            isFavorite: _isFavorite,
            onBack:     () => Navigator.of(context).maybePop(),
            onFavorite: () => setState(() => _isFavorite = !_isFavorite),
            onShare:    () {},
          ),

          // ── Bottom action bar ──────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomActionBar(isAvailable: _isAvailable, room: widget.room),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Header ──────────────────────────────────────────────────────────
class _FloatingHeader extends StatelessWidget {
  const _FloatingHeader({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
  });

  final bool         isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [Color(0x80000000), Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBack,
                ),
                Row(
                  children: [
                    _GlassIconButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      onTap: onFavorite,
                      iconColor:
                          isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _GlassIconButton(
                      icon: Icons.share_rounded,
                      onTap: onShare,
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
}

// ─── Glass Icon Button ────────────────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData     icon;
  final VoidCallback onTap;
  final Color        iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(-4, -4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(8, 8),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.room});
  final RoomData room;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh hero hoặc gradient fallback
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: room.imageUrl != null
                ? Image.network(
                    room.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, trace) => _gradientFallback(),
                  )
                : _gradientFallback(),
          ),

          // Gradient fade xuống
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end:   Alignment.center,
                colors: [kSurface, Colors.transparent],
              ),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),

          // Badge + tên phòng ở bottom
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: room.status == 'empty'
                        ? kPrimaryFixed
                        : kSurfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: kOnPrimaryFixed, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        room.status == 'empty'
                            ? 'Phòng trống'
                            : 'Đã có người thuê',
                        style: const TextStyle(
                          color: kOnPrimaryFixed,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Phòng ${room.roomNumber}',
                  style: const TextStyle(
                    color: kOnSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: kOnSurfaceVariant, size: 17),
                    const SizedBox(width: 4),
                    Text(
                      room.facility,
                      style: const TextStyle(
                        color: kOnSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryFixed, kPrimary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: const Center(
        child: Icon(Icons.house_rounded, color: Colors.white, size: 80),
      ),
    );
  }
}

// ─── Info Grid ────────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.room, required this.formatM});
  final RoomData                   room;
  final String Function(double)    formatM;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kOutlineVariant.withValues(alpha: 0.1),
                ),
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
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _InfoCell(
                      icon: Icons.payments_outlined,
                      value: '${formatM(room.price)}đ',
                      label: '/tháng',
                    ),
                    VerticalDivider(
                      color: kOutlineVariant.withValues(alpha: 0.2),
                      thickness: 1, width: 1,
                    ),
                    _InfoCell(
                      icon: Icons.savings_outlined,
                      value: '${formatM(room.deposit)}đ',
                      label: 'tiền cọc',
                    ),
                    VerticalDivider(
                      color: kOutlineVariant.withValues(alpha: 0.2),
                      thickness: 1, width: 1,
                    ),
                    _InfoCell(
                      icon: Icons.group_outlined,
                      value: '${room.maxTenants}',
                      label: 'người',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String   value;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kPrimary, size: 26),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Description Section ──────────────────────────────────────────────────────
class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả phòng',
            style: TextStyle(
              color: kOnSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              description,
              style: const TextStyle(
                color: kOnSurfaceVariant,
                fontSize: 14,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Amenities Section ────────────────────────────────────────────────────────
class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({
    required this.amenities,
    required this.iconMap,
  });

  final List<String>           amenities;
  final Map<String, IconData>  iconMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích',
            style: TextStyle(
              color: kOnSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((name) {
              final icon =
                  iconMap[name] ?? Icons.check_circle_outline_rounded;
              return _AmenityChip(icon: icon, label: name);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: kOutlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: kPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: kOnSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Action Bar ────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final bool isAvailable;
  final RoomData room;
  const _BottomActionBar({required this.isAvailable, required this.room});

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thông tin liên hệ',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kOnSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kSurfaceContainerHigh.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: kOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Landlord Card
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimary,
                            kPrimary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'ML',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chủ trọ',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 12,
                              color: kOnSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Minh Luân',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Phone Card with copy action
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: kSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kOutlineVariant.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_in_talk_rounded,
                        color: kPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số điện thoại',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 11,
                                color: kOnSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '0898449950',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: kOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Copy Button
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: '0898449950'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép số điện thoại chủ trọ!'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: kOutlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.copy_rounded,
                            color: kPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Dialog Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.w600,
                            color: kOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              kPrimary,
                              Color(0xFF4A84A9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: '0898449950'));
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép số điện thoại để gọi!'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text(
                            'Gọi điện',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: kOutlineVariant.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'Liên hệ chủ trọ',
                    onTap: () => _showContactDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GradientButton(
                    label: isAvailable
                        ? 'Gửi yêu cầu thuê'
                        : 'Phòng đã được thuê',
                    enabled: isAvailable,
                    onTap: isAvailable
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RentalRequestScreen(room: room),
                              ),
                            );
                          }
                        : () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class _OutlineButton extends StatefulWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String       label;
  final VoidCallback onTap;

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kSurfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: kOutlineVariant.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 8,
                offset: const Offset(-2, -2),
              ),
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });
  final String       label;
  final VoidCallback onTap;
  final bool         enabled;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   widget.enabled ? (_) => setState(() => _pressed = true)  : null,
      onTapUp:     widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false)  : null,
      onTap:       widget.enabled ? widget.onTap : null,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.85 : (widget.enabled ? 1.0 : 0.55),
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryFixedDim, kPrimary],
                  )
                : null,
            color: widget.enabled ? null : kSurfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.enabled ? kOnPrimary : kOutline,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
