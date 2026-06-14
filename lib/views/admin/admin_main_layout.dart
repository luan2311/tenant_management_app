import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/theme/styles.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'admin_home_page.dart';
import 'admin_contracts_page.dart';
import 'admin_rooms_page.dart';
import 'admin_statistics_page.dart';
import 'admin_tenants_page.dart';
import 'invoice_admin_screen.dart';

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
    const AdminContractsPage(),
    const AdminInvoicesPage(),
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
          child: IndexedStack(index: _currentIndex, children: _pages),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            color: Colors.white.withOpacity(0.18),
            child: GlassmorphicContainer(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              borderRadius: 26,
              opacity: 0.84,
              child: _AdminNavBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Admin Nav Bar ────────────────────────────────────────────────────

class _AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Trang chủ',
    ),
    (
      icon: Icons.meeting_room_outlined,
      activeIcon: Icons.meeting_room,
      label: 'Phòng',
    ),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Khách'),
    (
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Hợp đồng',
    ),
    (
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Hóa đơn',
    ),
    (
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Thống kê',
    ),
    (
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      label: 'Cá nhân',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_items.length, (i) {
        final active = i == currentIndex;
        final item = _items[i];
        return active
            ? Expanded(
                child: _AdminNavItem(
                  icon: item.activeIcon,
                  label: item.label,
                  isActive: true,
                  onTap: () => onTap(i),
                ),
              )
            : _AdminNavItem(
                icon: item.icon,
                label: item.label,
                isActive: false,
                onTap: () => onTap(i),
              );
      }),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.sanctuaryDark.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.sanctuaryDark
                  : AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppStyles.caption(
                  context,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.sanctuaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
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
            style: AppStyles.headline(
              context,
              color: AppColors.sanctuaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Quản trị viên Lumiere Stay', style: AppStyles.caption(context)),
          const SizedBox(height: 24),

          GlassmorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.accent,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'N/A',
                  style: AppStyles.title(
                    context,
                    color: AppColors.sanctuaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user?.email?.split('@').first ?? "admin"}',
                  style: AppStyles.caption(context),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  Icons.phone,
                  'Số điện thoại',
                  user?.phone ?? 'Chưa cập nhật',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  Icons.email,
                  'Email',
                  user?.email ?? 'Chưa cập nhật',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  Icons.security,
                  'Vai trò',
                  'Quản trị hệ thống (Admin)',
                ),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(context, appState),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.sanctuaryDark,
              side: BorderSide(
                color: AppColors.sanctuaryDark.withOpacity(0.24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.white.withOpacity(0.42),
            ),
            icon: const Icon(Icons.lock_reset_rounded),
            label: Text(
              'Đổi mật khẩu',
              style: AppStyles.body(
                context,
                color: AppColors.sanctuaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await appState.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.badgeMaintenanceText,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              'Đăng xuất',
              style: AppStyles.body(
                context,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 120), // Bottom navigation padding spacing
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    AppState appState,
  ) async {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    var isSubmitting = false;
    final result = await showDialog<PasswordChangeResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Đổi mật khẩu',
              style: AppStyles.title(
                dialogContext,
                color: AppColors.sanctuaryInk,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentController,
                    obscureText: true,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Vui lòng nhập mật khẩu hiện tại'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newController,
                    obscureText: true,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu mới',
                    ),
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
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Nhập lại mật khẩu mới',
                    ),
                    validator: (value) => value != newController.text
                        ? 'Mật khẩu nhập lại chưa khớp'
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
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
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() != true) return;
                        setDialogState(() => isSubmitting = true);
                        final changeResult = await appState
                            .changeCurrentUserPassword(
                              currentController.text,
                              newController.text,
                            );
                        if (!dialogContext.mounted) return;
                        if (changeResult.success) {
                          Navigator.of(dialogContext).pop(changeResult);
                          return;
                        }
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              changeResult.errorMessage ??
                                  'Không thể đổi mật khẩu. Vui lòng thử lại.',
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sanctuaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  'Lưu',
                  style: AppStyles.body(
                    dialogContext,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (!context.mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Đã cập nhật mật khẩu admin.'
              : 'Mật khẩu hiện tại không đúng.',
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.sanctuaryDark.withOpacity(0.7)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppStyles.caption(context)),
            Text(
              value,
              style: AppStyles.body(context, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
