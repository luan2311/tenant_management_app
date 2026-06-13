import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';

// HUY.4.2 · Sprint 4 — Trung tâm thông báo, hiển thị dưới dạng tab trong TenantShell.

// ─── Accent colors chưa có trong app_theme.dart ──────────────────────────────
const _kError = Color(0xFFA83836);
const _kErrorContainer = Color(0xFFFA746F);
const _kOnPrimaryContainer = Color(0xFF0D4C6D);
const _kSecondary = Color(0xFF50616F);
const _kTertiary = Color(0xFF585C85);

// ─── Data models ──────────────────────────────────────────────────────────────
enum NotificationCategory { today, lastWeek }

class NotificationItem {
  final String title;
  final String body;
  final String time;
  final Color accentColor;      // màu thanh bên trái + icon bg
  final Color iconColor;
  final IconData icon;
  final bool isRead;
  final bool isUrgent;
  final String? amount;         // chỉ có ở card thanh toán
  final String? tag;            // chỉ có ở card hợp đồng
  final NotificationCategory category;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.accentColor,
    required this.iconColor,
    required this.icon,
    this.isRead = false,
    this.isUrgent = false,
    this.amount,
    this.tag,
    required this.category,
  });
}

// Dữ liệu mẫu map từ các card trong HTML
final List<NotificationItem> _notifications = [
  NotificationItem(
    title: 'Nhắc nhở thanh toán tháng 10',
    body:
        'Hóa đơn tiền phòng và dịch vụ tháng 10/2023 của phòng 302 đã được tạo. Vui lòng thanh toán trước ngày 05/11.',
    time: '09:30',
    accentColor: _kErrorContainer,
    iconColor: _kErrorContainer,
    icon: Icons.receipt_long,
    isUrgent: true,
    amount: '4.500.000 ₫',
    category: NotificationCategory.today,
  ),
  NotificationItem(
    title: 'Hợp đồng sắp hết hạn',
    body:
        'Hợp đồng thuê phòng 302 của bạn sẽ hết hạn vào ngày 30/11/2023. Vui lòng liên hệ chủ nhà để gia hạn hoặc làm thủ tục trả phòng.',
    time: 'Hôm qua',
    accentColor: kTertiaryContainer,
    iconColor: _kTertiary,
    icon: Icons.description,
    tag: 'Còn 25 ngày',
    category: NotificationCategory.today,
  ),
  NotificationItem(
    title: 'Lịch bảo trì thang máy',
    body:
        'Ban quản lý thông báo sẽ tiến hành bảo trì thang máy tòa nhà từ 08:00 đến 12:00 ngày 22/10. Mong quý khách thông cảm.',
    time: '20/10',
    accentColor: kSecondaryContainer,
    iconColor: _kSecondary,
    icon: Icons.campaign,
    isRead: true,
    category: NotificationCategory.lastWeek,
  ),
  NotificationItem(
    title: 'Thông báo cúp nước tạm thời',
    body:
        'Khu vực sẽ bị cúp nước từ 22:00 đêm nay đến 05:00 sáng mai để sửa chữa đường ống chính.',
    time: '15/10',
    accentColor: kSecondaryContainer,
    iconColor: _kSecondary,
    icon: Icons.water_drop,
    isRead: true,
    category: NotificationCategory.lastWeek,
  ),
];

// ─── Main screen ─────────────────────────────────────────────────────────────
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    // Không tự vẽ Scaffold + bottom nav riêng — màn hình này chạy như 1 tab
    // bên trong TenantShell (IndexedStack), đã có LumiereBottomNavBar.tenant().
    return Scaffold(
      backgroundColor: kSurface,
      body: Stack(
        children: [
          // Background radial gradient blobs (map từ CSS body background-image)
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mobile sticky header
                _MobileHeader(
                  onMarkAllRead: _markAllRead,
                ),

                // Notification list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      // ── Hôm nay ──
                      const _DateDivider(label: 'HÔM NAY'),
                      const SizedBox(height: 12),
                      ..._notifications
                          .where((n) => n.category == NotificationCategory.today)
                          .map((n) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCard(item: n),
                              )),

                      const SizedBox(height: 8),
                      // ── Tuần trước ──
                      const _DateDivider(label: 'TUẦN TRƯỚC'),
                      const SizedBox(height: 12),
                      ..._notifications
                          .where((n) => n.category == NotificationCategory.lastWeek)
                          .map((n) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCard(item: n),
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _markAllRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả là đã đọc'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Background radial gradient painter ───────────────────────────────────────
// Map từ CSS:
//   radial-gradient(circle at 100% 0%, primary-fixed, transparent 40%)
//   radial-gradient(circle at 0% 100%, secondary-fixed, transparent 40%)
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topRight = RadialGradient(
      center: Alignment.topRight,
      radius: 0.8,
      colors: [kPrimaryFixed.withValues(alpha: 0.35), Colors.transparent],
    );
    final bottomLeft = RadialGradient(
      center: Alignment.bottomLeft,
      radius: 0.8,
      colors: [kSecondaryContainer.withValues(alpha: 0.35), Colors.transparent],
    );

    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = topRight.createShader(rect));
    canvas.drawRect(rect, Paint()..shader = bottomLeft.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Mobile sticky header ─────────────────────────────────────────────────────
class _MobileHeader extends StatelessWidget {
  final VoidCallback onMarkAllRead;

  const _MobileHeader({required this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: kSurface.withValues(alpha: 0.8),
        // backdrop blur giả lập bằng color opacity
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cập nhật mới nhất',
                style: TextStyle(
                  fontSize: 12,
                  color: kOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // "Đánh dấu đã đọc" button (icon only cho mobile)
          GestureDetector(
            onTap: onMarkAllRead,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14596064),
                    blurRadius: 16,
                    offset: Offset(8, 8),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 16,
                    offset: Offset(-4, -4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.done_all,
                color: kPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date divider ─────────────────────────────────────────────────────────────
// Map từ <div class="flex items-center gap-4"> trong HTML
class _DateDivider extends StatelessWidget {
  final String label;

  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: kOnSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: kOutlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────
// Map từ các .glass-panel card trong HTML
// 3 trạng thái: urgent (có amount + button), warning (có tag chip), read (opacity 0.8)
class _NotificationCard extends StatefulWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: item.isRead ? 0.8 : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kOutlineVariant.withValues(alpha: 0.15),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 16,
                      offset: Offset(-4, -4),
                    ),
                    BoxShadow(
                      color: Color(0x14596064),
                      blurRadius: 16,
                      offset: Offset(8, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Thanh màu bên trái (unread indicator)
                    // Map từ <div class="absolute top-0 left-0 w-1 h-full">
                    if (!item.isRead)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: item.accentColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),

                    // Card content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon circle
                          _NotificationIcon(item: item),
                          const SizedBox(width: 16),

                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + time
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: item.isRead
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          color: kOnSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.time,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kOnSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Body text
                                Text(
                                  item.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kOnSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),

                                // Amount row (urgent payment card)
                                if (item.amount != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        item.amount!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _kError,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _ActionChip(label: 'Xem hóa đơn'),
                                    ],
                                  ),
                                ],

                                // Tag chip (contract expiry)
                                if (item.tag != null) ...[
                                  const SizedBox(height: 10),
                                  _TagChip(label: item.tag!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
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

// ─── Icon circle cho từng notification ───────────────────────────────────────
class _NotificationIcon extends StatelessWidget {
  final NotificationItem item;

  const _NotificationIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: item.accentColor.withValues(alpha: item.isRead ? 0.25 : 0.20),
      ),
      child: Icon(
        item.icon,
        color: item.iconColor,
        size: 22,
      ),
    );
  }
}

// ─── "Xem hóa đơn" action button chip ────────────────────────────────────────
// Map từ <button class="px-4 py-2 rounded-full bg-primary-container">
class _ActionChip extends StatelessWidget {
  final String label;

  const _ActionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: kPrimaryFixed,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kOnPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

// ─── Tag chip "Còn 25 ngày" ───────────────────────────────────────────────────
// Map từ <span class="inline-block px-3 py-1 rounded-full bg-surface-container-high">
class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: kOnSurface,
        ),
      ),
    );
  }
}
