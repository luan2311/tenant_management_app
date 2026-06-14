import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/models/notification.dart';
import 'package:tenant_management_app/views/tenant/my_invoice_screen.dart';

// HUY.4.2 · Sprint 4 — Trung tâm thông báo, hiển thị dưới dạng tab trong TenantShell.

// ─── Accent colors chưa có trong app_theme.dart ──────────────────────────────
const _kError = Color(0xFFA83836);
const _kErrorContainer = Color(0xFFFA746F);
const _kOnPrimaryContainer = Color(0xFF0D4C6D);
const _kSecondary = Color(0xFF50616F);
const _kTertiary = Color(0xFF585C85);

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  
  bool _isToday(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  void _markAllRead(BuildContext context) {
    context.read<AppState>().markAllNotificationsAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả là đã đọc'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifications = appState.notifications;

    final todayNotifications = notifications.where((n) => _isToday(n.createdAt)).toList();
    final olderNotifications = notifications.where((n) => !_isToday(n.createdAt)).toList();

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
                  onMarkAllRead: () => _markAllRead(context),
                ),

                // Notification list
                Expanded(
                  child: notifications.isEmpty
                      ? const _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                          children: [
                            // ── Hôm nay ──
                            if (todayNotifications.isNotEmpty) ...[
                              const _DateDivider(label: 'HÔM NAY'),
                              const SizedBox(height: 12),
                              ...todayNotifications.map((n) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _NotificationCard(item: n),
                                  )),
                              const SizedBox(height: 8),
                            ],

                            // ── Trước đó ──
                            if (olderNotifications.isNotEmpty) ...[
                              const _DateDivider(label: 'TRƯỚC ĐÓ'),
                              const SizedBox(height: 12),
                              ...olderNotifications.map((n) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _NotificationCard(item: n),
                                  )),
                            ],
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
}

// ─── Background radial gradient painter ───────────────────────────────────────
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cập nhật mới nhất',
                style: TextStyle(
                  fontSize: 12,
                  color: kOnSurfaceVariant,
                ),
              ),
              SizedBox(height: 2),
              Text(
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
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
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
class _NotificationCard extends StatefulWidget {
  final NotificationModel item;

  const _NotificationCard({required this.item});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _pressed = false;

  String _formatCreatedAt(String createdAtStr) {
    try {
      final date = DateTime.parse(createdAtStr);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        final hour = date.hour.toString().padLeft(2, '0');
        final minute = date.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        return 'Hôm qua';
      } else {
        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        return '$day/$month';
      }
    } catch (e) {
      return createdAtStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isRead = item.isRead == 1;

    // Default styles for 'facility_notice' or general notices
    IconData iconData = Icons.campaign;
    Color accentColor = kSecondaryContainer;
    Color iconColor = _kSecondary;
    String? amount;
    String? tag;

    if (item.type == 'rent_reminder') {
      iconData = Icons.receipt_long;
      accentColor = _kErrorContainer;
      iconColor = _kError;
      // Extract amount from content if available
      final match = RegExp(r'(\d+[\d\.,]*\s*[₫đ])').firstMatch(item.content);
      if (match != null) {
        amount = match.group(0);
      }
    } else if (item.type == 'contract_expiry') {
      iconData = Icons.description;
      accentColor = kTertiaryContainer;
      iconColor = _kTertiary;
      // Extract remaining days from content
      final match = RegExp(r'sau (\d+) ngày').firstMatch(item.content);
      if (match != null) {
        tag = 'Còn ${match.group(1)} ngày';
      } else if (item.content.contains('hết hạn')) {
        tag = 'Hết hạn';
      }
    } else if (item.type == 'payment_success') {
      iconData = Icons.celebration;
      accentColor = kPrimaryFixed;
      iconColor = kPrimary;
    } else if (item.type == 'booking_request') {
      iconData = Icons.add_home;
      accentColor = kPrimaryFixed;
      iconColor = kPrimary;
    } else if (item.type == 'facility_notice') {
      final contentLower = item.content.toLowerCase();
      final titleLower = item.title.toLowerCase();
      if (contentLower.contains('nước') || titleLower.contains('nước')) {
        iconData = Icons.water_drop;
        accentColor = const Color(0xFFD0E8FF);
        iconColor = Colors.blue;
      } else if (contentLower.contains('điện') || titleLower.contains('điện')) {
        iconData = Icons.bolt;
        accentColor = const Color(0xFFFFF0D0);
        iconColor = Colors.amber.shade800;
      } else if (contentLower.contains('bảo trì') || titleLower.contains('bảo trì') || contentLower.contains('thang máy') || titleLower.contains('thang máy')) {
        iconData = Icons.construction;
        accentColor = const Color(0xFFFFEAD0);
        iconColor = Colors.orange;
      }
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (!isRead) {
          context.read<AppState>().readNotification(item.id!);
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: isRead ? 0.8 : 1.0,
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
                    if (!isRead)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: iconColor,
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
                          _NotificationIcon(
                            icon: iconData,
                            accentColor: accentColor,
                            iconColor: iconColor,
                            isRead: isRead,
                          ),
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
                                          fontWeight: isRead
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          color: kOnSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatCreatedAt(item.createdAt),
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
                                  item.content,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kOnSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),

                                // Amount row (urgent payment card)
                                if (item.type == 'rent_reminder') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (amount != null) ...[
                                        Text(
                                          amount,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _kError,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      _ActionChip(
                                        label: 'Xem hóa đơn',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const MyInvoiceScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],

                                // Tag chip (contract expiry)
                                if (tag != null) ...[
                                  const SizedBox(height: 10),
                                  _TagChip(label: tag),
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
  final IconData icon;
  final Color accentColor;
  final Color iconColor;
  final bool isRead;

  const _NotificationIcon({
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: isRead ? 0.25 : 0.20),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
    );
  }
}

// ─── "Xem hóa đơn" action button chip ────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: kOutlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chưa có thông báo nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kOnSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Các cập nhật tiền phòng, hợp đồng và thông báo từ ban quản lý cơ sở sẽ xuất hiện ở đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: kOnSurfaceVariant.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
