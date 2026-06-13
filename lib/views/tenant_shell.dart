import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/widgets/bottom_nav_bar.dart';
import 'customer/home_page_screen.dart';
import 'customer/explore_screen.dart';
import 'customer/notification_screen.dart';
import 'customer/profile_screen.dart';
import 'tenant/my_room_screen.dart';

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
          const MyRoomScreen(),
          const NotificationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: LumiereBottomNavBar.tenant(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}
