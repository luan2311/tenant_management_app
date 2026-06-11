import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/styles.dart';
import '../../service/app_state.dart';
import 'admin_home_page.dart';
import 'admin_rooms_page.dart';
import 'admin_statistics_page.dart';
import 'admin_tenants_page.dart';
import '../login_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomePage(),
    const AdminRoomsPage(),
    const AdminTenantsPage(),
    const AdminStatisticsPage(),
    const AdminProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: EtherealBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(vertical: 7),
          borderRadius: 26,
          opacity: 0.84,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.sanctuaryDark,
            unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
            selectedLabelStyle: AppStyles.caption(context, fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: AppStyles.caption(context, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.meeting_room_outlined),
                activeIcon: Icon(Icons.meeting_room),
                label: 'Phòng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Khách',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Thống kê',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Profile Page (Task LUAN.4.1)
class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cá nhân',
            style: AppStyles.headline(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Quản trị viên Lumiere Stay',
            style: AppStyles.caption(context),
          ),
          const SizedBox(height: 24),
          
          GlassmorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'N/A',
                  style: AppStyles.title(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user?.username ?? "admin"}',
                  style: AppStyles.caption(context),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                _buildInfoRow(context, Icons.phone, 'Số điện thoại', user?.phone ?? 'Chưa cập nhật'),
                const SizedBox(height: 16),
                _buildInfoRow(context, Icons.email, 'Email', user?.email ?? 'Chưa cập nhật'),
                const SizedBox(height: 16),
                _buildInfoRow(context, Icons.security, 'Vai trò', 'Quản trị hệ thống (Admin)'),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(context, appState),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.sanctuaryDark,
              side: BorderSide(color: AppColors.sanctuaryDark.withOpacity(0.24)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.white.withOpacity(0.42),
            ),
            icon: const Icon(Icons.lock_reset_rounded),
            label: Text(
              'Đổi mật khẩu',
              style: AppStyles.body(context, color: AppColors.sanctuaryDark, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await appState.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.badgeMaintenanceText,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              'Đăng xuất',
              style: AppStyles.body(context, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 120), // Bottom navigation padding spacing
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, AppState appState) async {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Đổi mật khẩu',
            style: AppStyles.title(dialogContext, color: AppColors.sanctuaryInk, fontWeight: FontWeight.w900),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mật khẩu mới cần ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
                  validator: (value) => value != newController.text ? 'Mật khẩu nhập lại chưa khớp' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Hủy', style: AppStyles.body(dialogContext, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;
                final changed = await appState.changeCurrentUserPassword(
                  currentController.text,
                  newController.text,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(changed);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sanctuaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text('Lưu', style: AppStyles.body(dialogContext, color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (!context.mounted || success == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã cập nhật mật khẩu admin.' : 'Mật khẩu hiện tại không đúng.'),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.sanctuaryDark.withOpacity(0.7)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppStyles.caption(context),
            ),
            Text(
              value,
              style: AppStyles.body(context, fontWeight: FontWeight.w600),
            ),
          ],
        )
      ],
    );
  }
}
