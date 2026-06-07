import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'customer/Home_page_screen.dart';
import 'customer/Explore_screen.dart';
import 'customer/Notification_screen.dart';

/// Shell quản lý Bottom Navigation cho phân hệ Khách thuê.
/// Tab 0: Trang chủ, Tab 1: Khám phá, Tab 2: Phòng của tôi, Tab 3: Thông báo.
class TenantShell extends StatefulWidget {
  const TenantShell({super.key});

  @override
  State<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends State<TenantShell> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      // IndexedStack giữ state của tất cả tab khi chuyển qua lại.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onViewAll: () => _switchTab(1)),
          const ExploreScreen(),
          const _PlaceholderTab(
            'Phòng của tôi',
            Icons.meeting_room_rounded,
            'Sprint 3 — Gia Khánh',
          ),
          const NotificationScreen(),
        ],
      ),
      bottomNavigationBar: LumiereBottomNavBar.tenant(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final String note;

  const _PlaceholderTab(this.title, this.icon, this.note);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: kPrimary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kOnSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Đang phát triển · $note',
              style: const TextStyle(fontSize: 13, color: kOnSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
