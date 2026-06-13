import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tenant_management_app/services/auth_service.dart';
import 'package:tenant_management_app/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 32),
                      _buildResetCard(),
                      const SizedBox(height: 32),
                      _buildSecurityBadge(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFDCEFF9), Color(0xFFF7F9FB), Color(0xFFEFF5FA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            left: -70,
            child: _blurCircle(300, kPrimaryFixed.withValues(alpha: 0.3), 80),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _blurCircle(
              340,
              kSecondaryContainer.withValues(alpha: 0.28),
              90,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color, double blur) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryFixed, kPrimary],
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lumiere Stay',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: kOnSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _emailSent ? 'Tạo mật khẩu mới' : 'Khôi phục quyền truy cập',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kOnSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildResetCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.08),
                blurRadius: 48,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _emailSent ? _buildChangePasswordStep() : _buildEmailStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kOnSurface,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập email tài khoản. Firebase sẽ gửi link đặt lại mật khẩu, bạn có thể dán toàn bộ link hoặc mã oobCode vào bước tiếp theo.',
          style: TextStyle(fontSize: 13, color: kOnSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 28),
        _buildInputLabel('Email'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hint: 'lumiere@gmail.com',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Gửi link đặt lại',
          icon: Icons.mark_email_read_outlined,
          onPressed: _sendResetEmail,
        ),
        const SizedBox(height: 24),
        _buildBackLink(),
      ],
    );
  }

  Widget _buildChangePasswordStep() {
    return Column(
      key: const ValueKey('change-password-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kOnSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Email đã gửi tới ${_emailController.text.trim()}. Kiểm tra hộp thư hoặc spam, sau đó dán link đặt lại mật khẩu vào đây.',
          style: const TextStyle(
            fontSize: 13,
            color: kOnSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildInputLabel('Link reset hoặc mã oobCode'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _codeController,
          hint: 'Dán link từ email Firebase',
          icon: Icons.key_rounded,
        ),
        const SizedBox(height: 18),
        _buildInputLabel('Mật khẩu mới'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _newPasswordController,
          hint: 'Tối thiểu 6 ký tự',
          obscureText: _obscureNewPassword,
          onToggle: () =>
              setState(() => _obscureNewPassword = !_obscureNewPassword),
        ),
        const SizedBox(height: 18),
        _buildInputLabel('Nhập lại mật khẩu'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hint: 'Nhập lại mật khẩu mới',
          obscureText: _obscureConfirmPassword,
          onToggle: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Cập nhật mật khẩu',
          icon: Icons.check_circle_outline_rounded,
          onPressed: _confirmNewPassword,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _isLoading ? null : _sendResetEmail,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Gửi lại link đặt lại'),
          ),
        ),
        const SizedBox(height: 10),
        _buildBackLink(),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kOnSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: kOnSurface),
      decoration: _inputDecoration(hint: hint, icon: icon),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: kOnSurface),
      decoration: _inputDecoration(hint: hint, icon: Icons.lock_outline_rounded)
          .copyWith(
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: kOutline,
                size: 21,
              ),
            ),
          ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: kOutline.withValues(alpha: 0.7),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: kOutline, size: 22),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.58),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryFixed, width: 2),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryFixed, kPrimary],
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: kOnPrimaryFixed,
                    strokeWidth: 2,
                  ),
                )
              : Icon(icon, color: kOnPrimaryFixed, size: 20),
          label: Text(
            _isLoading ? 'Đang xử lý...' : label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kOnPrimaryFixed,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildBackLink() {
    return Center(
      child: TextButton.icon(
        onPressed: _isLoading ? null : () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Quay lại đăng nhập'),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Opacity(
      opacity: 0.55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.verified_user_outlined,
            color: kOnSurfaceVariant,
            size: 15,
          ),
          SizedBox(width: 6),
          Text(
            'SECURE PASSWORD RESET',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: kOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showSnackBar('Vui lòng nhập email hợp lệ.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _emailSent = true);
      _showSnackBar(
        'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(_firebaseResetMessage(e));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Gửi email thất bại. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmNewPassword() async {
    final code = _extractResetCode(_codeController.text);
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (code == null) {
      _showSnackBar('Vui lòng dán link reset hoặc mã oobCode từ email.');
      return;
    }
    if (newPassword.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnackBar('Mật khẩu nhập lại không khớp.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.verifyPasswordResetCode(code);
      await AuthService.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      if (!mounted) return;
      _showSnackBar('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(_firebaseConfirmMessage(e));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Không thể đổi mật khẩu. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  String? _extractResetCode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    final code = uri?.queryParameters['oobCode'];
    if (code != null && code.trim().isNotEmpty) return code.trim();

    final nestedLink = uri?.queryParameters['link'];
    if (nestedLink != null) {
      final nestedCode = _extractResetCode(Uri.decodeComponent(nestedLink));
      if (nestedCode != null) return nestedCode;
    }

    final fragmentCode = RegExp(
      r'(?:[?&#]|^)oobCode=([^&]+)',
    ).firstMatch(trimmed)?.group(1);
    if (fragmentCode != null && fragmentCode.trim().isNotEmpty) {
      return Uri.decodeComponent(fragmentCode.trim());
    }

    return trimmed;
  }

  String _firebaseResetMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'too-many-requests':
        return 'Bạn đã yêu cầu quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi mạng. Kiểm tra kết nối internet rồi thử lại.';
      default:
        return 'Gửi email thất bại: ${e.message ?? e.code}';
    }
  }

  String _firebaseConfirmMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'expired-action-code':
        return 'Link đặt lại đã hết hạn. Vui lòng gửi lại email.';
      case 'invalid-action-code':
        return 'Link đặt lại không hợp lệ hoặc đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản tương ứng với mã này.';
      case 'network-request-failed':
        return 'Lỗi mạng. Kiểm tra kết nối internet rồi thử lại.';
      default:
        return 'Đổi mật khẩu thất bại: ${e.message ?? e.code}';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }
}
