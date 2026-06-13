import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// ─── Main Login Screen ────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    children: [
                      _buildBrandSection(),
                      const SizedBox(height: 40),
                      _buildLoginCard(),
                      const SizedBox(height: 40),
                      _buildFooterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildHelpButton(),
          ),
        ],
      ),
    );
  }

  // ─── Background ────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDCEFF9),
            Color(0xFFF7F9FB),
            Color(0xFFEFF5FA),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryFixed.withValues(alpha: 0.35),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSecondaryContainer.withValues(alpha: 0.25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Brand Section ─────────────────────────────────────────────────────────

  Widget _buildBrandSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.house_siding_rounded,
                size: 40,
                color: kPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Lumiere Stay',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: kOnSurface,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ethereal Sanctuary Management',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: kOnSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ─── Login Card ────────────────────────────────────────────────────────────

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.08),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng trở lại',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Vui lòng đăng nhập để tiếp tục quản lý',
                style: TextStyle(fontSize: 13, color: kOnSurfaceVariant),
              ),
              const SizedBox(height: 32),
              _buildInputLabel('Email hoặc Số điện thoại'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'example@lumiere.com',
                prefixIcon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel('Mật khẩu'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPasswordField(),
              const SizedBox(height: 28),
              _buildLoginButton(),
              const SizedBox(height: 32),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildBiometricButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input Helpers ─────────────────────────────────────────────────────────

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kOnSurfaceVariant,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, color: kOnSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: kOutline.withValues(alpha: 0.6), fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: kOutline, size: 22),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.55),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryFixed, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 15, color: kOnSurface),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(
            color: kOutline.withValues(alpha: 0.6), fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: kOutline, size: 22),
        suffixIcon: IconButton(
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: kOutline,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.55),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryFixed, width: 2),
        ),
      ),
    );
  }

  // ─── Login Button ──────────────────────────────────────────────────────────

  Widget _buildLoginButton() {
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
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: kOnPrimaryFixed,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kOnPrimaryFixed,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: kOnPrimaryFixed, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // TODO Sprint 5: Thay bằng DatabaseHelper.getUserByCredentials(email, password)
      await Future.delayed(const Duration(milliseconds: 600));
      await AuthService.saveSession(
          userId: 1, role: 'tenant', name: email);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng nhập thất bại. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Divider ───────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, kSurfaceContainerHigh],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'HOẶC ĐĂNG NHẬP NHANH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: kOutline.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kSurfaceContainerHigh, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Biometric Buttons ─────────────────────────────────────────────────────

  Widget _buildBiometricButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGoogleLoginButton(onTap: () {
          _handleGoogleLogin();
        }),
        const SizedBox(width: 24),
        _buildBiometricButton(
            icon: Icons.face_retouching_natural_rounded, onTap: () {}),
      ],
    );
  }

  Future<void> _handleGoogleLogin() async {
    // TODO: Implement Google sign-in flow.
  }

  Widget _buildGoogleLoginButton({
    required VoidCallback onTap,
  }) {
    return _buildQuickLoginButton(
      onTap: onTap,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBiometricButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _buildQuickLoginButton(
      onTap: onTap,
      child: Icon(icon, color: kPrimary, size: 30),
    );
  }

  Widget _buildQuickLoginButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  // ─── Footer Link ───────────────────────────────────────────────────────────

  Widget _buildFooterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản?',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: kOnSurfaceVariant,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text(
            'Đăng ký ngay',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: kPrimary,
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: kPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Help Button ───────────────────────────────────────────────────────────

  Widget _buildHelpButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.help_outline_rounded,
              color: kPrimary, size: 22),
        ),
      ),
    );
  }
}
