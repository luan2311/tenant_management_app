import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final name = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Khách thuê';
    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!.trim()
        : 'Chưa cập nhật';
    final phone = user?.phone?.trim().isNotEmpty == true
        ? user!.phone!.trim()
        : 'Chưa cập nhật';

    final activeData = appState.activeRoomData;
    final String roomText;
    final String invoiceText;

    if (user?.role == 'admin') {
      roomText = '${appState.rooms.length} phòng';
      invoiceText = '${appState.invoices.length} hóa đơn';
    } else {
      final room = activeData?['room'];
      roomText = room != null ? 'P.${room['room_number']}' : 'Chưa có';
      final invoiceCount = activeData?['invoices']?.length ?? 0;
      invoiceText = '$invoiceCount';
    }

    return Scaffold(
      backgroundColor: kSurface,
      body: Stack(
        children: [
          const Positioned.fill(child: _ProfileBackground()),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                const _ProfileHeader(),
                const SizedBox(height: 20),
                _IdentityCard(
                  name: name,
                  email: email,
                  role: user?.role == 'admin' ? 'Quản trị viên' : 'Khách thuê',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.home_work_outlined,
                        label: user?.role == 'admin'
                            ? 'Tổng số phòng'
                            : 'Phòng',
                        value: roomText,
                        tint: kPrimaryFixed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.receipt_long_outlined,
                        label: user?.role == 'admin'
                            ? 'Tổng hóa đơn'
                            : 'Hóa đơn',
                        value: invoiceText,
                        tint: kTertiaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  children: [
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Số điện thoại',
                      value: phone,
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                    _InfoRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Phương thức đăng nhập',
                      value: user?.provider == 'google'
                          ? 'Google'
                          : 'Email và mật khẩu',
                    ),
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Ngày tham gia',
                      value: _formatDate(user?.createdAt),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ActionSection(
                  onChangePassword: () {
                    if (user?.provider == 'google') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tài khoản Google không đổi mật khẩu trong app.',
                          ),
                        ),
                      );
                      return;
                    }
                    _showChangePasswordDialog(context, appState);
                  },
                  onLogout: () => _logout(context, appState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return 'Chưa cập nhật';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  Future<void> _logout(BuildContext context, AppState appState) async {
    await appState.logout();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
            title: const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontWeight: FontWeight.w800),
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
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) => value == null || value.isEmpty
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
                      prefixIcon: Icon(Icons.password_outlined),
                    ),
                    validator: (value) => value == null || value.length < 6
                        ? 'Mật khẩu mới cần ít nhất 6 ký tự'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmController,
                    obscureText: true,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Nhập lại mật khẩu mới',
                      prefixIcon: Icon(Icons.check_circle_outline),
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
                child: const Text('Hủy'),
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
                                  'Không thể đổi mật khẩu. Vui lòng kiểm tra lại.',
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
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
                label: const Text('Lưu'),
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
              ? 'Đã cập nhật mật khẩu.'
              : 'Không thể đổi mật khẩu. Vui lòng kiểm tra lại.',
        ),
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ProfileBackgroundPainter());
  }
}

class _ProfileBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final top = RadialGradient(
      center: Alignment.topLeft,
      radius: 0.8,
      colors: [kPrimaryFixed.withValues(alpha: 0.36), Colors.transparent],
    );
    final bottom = RadialGradient(
      center: Alignment.bottomRight,
      radius: 0.75,
      colors: [kTertiaryContainer.withValues(alpha: 0.28), Colors.transparent],
    );
    canvas.drawRect(rect, Paint()..shader = top.createShader(rect));
    canvas.drawRect(rect, Paint()..shader = bottom.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tài khoản',
          style: TextStyle(
            color: kOnSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: kOnSurface,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryFixed, kPrimary],
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kOnSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kPrimaryFixed.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              role,
              style: const TextStyle(
                color: kOnPrimaryFixed,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'KT';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimary, size: 21),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: kOnSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kPrimary, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: kOnSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kOnSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.onChangePassword,
    required this.onLogout,
  });

  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: onChangePassword,
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: BorderSide(color: kPrimary.withValues(alpha: 0.32)),
            backgroundColor: Colors.white.withValues(alpha: 0.52),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.lock_reset_rounded),
          label: const Text(
            'Đổi mật khẩu',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA83836),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.logout_rounded),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kOutlineVariant.withValues(alpha: 0.18)),
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
          child: child,
        ),
      ),
    );
  }
}
