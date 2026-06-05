import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Định nghĩa item cho Bottom Nav ──────────────────────────────────────────

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Preset items cho từng phân hệ ────────────────────────────────────────────

const _tenantItems = [
  NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Trang chủ',
  ),
  NavItem(
    icon: Icons.search_outlined,
    activeIcon: Icons.search_rounded,
    label: 'Khám phá',
  ),
  NavItem(
    icon: Icons.meeting_room_outlined,
    activeIcon: Icons.meeting_room_rounded,
    label: 'Phòng của tôi',
  ),
  NavItem(
    icon: Icons.notifications_none_rounded,
    activeIcon: Icons.notifications_rounded,
    label: 'Thông báo',
  ),
];

const _adminItems = [
  NavItem(
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label: 'Tổng quan',
  ),
  NavItem(
    icon: Icons.apartment_outlined,
    activeIcon: Icons.apartment_rounded,
    label: 'Phòng',
  ),
  NavItem(
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    label: 'Khách thuê',
  ),
  NavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'Hóa đơn',
  ),
  NavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Thống kê',
  ),
];

// ─── Widget chính ─────────────────────────────────────────────────────────────

/// Bottom Navigation Bar phong cách Glassmorphism dùng chung.
///
/// Sử dụng:
/// ```dart
/// LumiereBottomNavBar.tenant(currentIndex: _index, onTap: (i) => setState(() => _index = i))
/// LumiereBottomNavBar.admin(currentIndex: _index, onTap: (i) => setState(() => _index = i))
/// ```
class LumiereBottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LumiereBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  /// Preset cho phân hệ Khách thuê (4 tab).
  factory LumiereBottomNavBar.tenant({
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return LumiereBottomNavBar(
      items: _tenantItems,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }

  /// Preset cho phân hệ Admin / Chủ trọ (5 tab).
  factory LumiereBottomNavBar.admin({
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return LumiereBottomNavBar(
      items: _adminItems,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final active = i == currentIndex;
                return _NavTabItem(
                  item: items[i],
                  isActive: active,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Item trong tab ────────────────────────────────────────────────────────────

class _NavTabItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: kPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive ? kPrimary : kOutline,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? kPrimary : kOutline,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
