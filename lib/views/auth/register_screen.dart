import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tenant_management_app/services/auth_service.dart';

// ─── Register Screen ──────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _submitted = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? get _nameError {
    final value = _nameController.text.trim();
    if (value.isEmpty) return 'Vui lòng nhập họ tên.';
    if (value.length < 2) return 'Họ tên phải có ít nhất 2 ký tự.';
    return null;
  }

  String? get _phoneError {
    final value = _phoneController.text.trim();
    final normalized = value.replaceAll(RegExp(r'[\s.-]'), '');
    if (value.isEmpty) return 'Vui lòng nhập số điện thoại.';
    if (!RegExp(r'^0\d{9}$').hasMatch(normalized)) {
      return 'Số điện thoại gồm 10 chữ số và bắt đầu bằng 0.';
    }
    return null;
  }

  String? get _emailError {
    final value = _emailController.text.trim();
    if (value.isEmpty) return 'Vui lòng nhập email.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Email phải đúng định dạng, ví dụ lumiere@gmail.com.';
    }
    return null;
  }

  String? get _passwordError {
    final value = _passwordController.text;
    if (value.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
    return null;
  }

  String? get _confirmError {
    final value = _confirmController.text;
    if (value.isEmpty) return 'Vui lòng nhập lại mật khẩu.';
    if (value != _passwordController.text) {
      return 'Mật khẩu nhập lại phải trùng với mật khẩu.';
    }
    return null;
  }

  String? get _termsError {
    if (!_agreedToTerms) {
      return 'Bạn cần đồng ý với Điều khoản dịch vụ và Chính sách bảo mật.';
    }
    return null;
  }

  bool get _isFormValid =>
      _nameError == null &&
      _phoneError == null &&
      _emailError == null &&
      _passwordError == null &&
      _confirmError == null &&
      _termsError == null;

  void _refreshSubmittedErrors() {
    if (_submitted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024; // lg breakpoint

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Nền gradient + orbs
          _buildBackground(),

          // Layer 2: Nội dung chính
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: isWide
                    ? _buildWideLayout() // Desktop: 2 cột
                    : _buildNarrowLayout(), // Mobile: 1 cột
              ),
            ),
          ),

          // Layer 3: Floating pills góc dưới phải
          Positioned(bottom: 40, right: 40, child: _buildFloatingStatus()),
        ],
      ),
    );
  }

  // ─── Background ────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBF4FB), Color(0xFFF7F9FB), Color(0xFFEEEEFD)],
        ),
      ),
      child: Stack(
        children: [
          // Orb trên trái (primary-container/30)
          Positioned(
            top: -80,
            left: -80,
            child: _blurOrb(320, kPrimaryFixed.withValues(alpha: 0.3), 80),
          ),
          // Orb dưới phải (tertiary-container/30)
          Positioned(
            bottom: -80,
            right: -80,
            child: _blurOrb(320, kTertiaryContainer.withValues(alpha: 0.3), 80),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb(double size, Color color, double blurRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ─── Layout 2 cột (Desktop) ────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cột trái: Branding
          Expanded(child: _buildBrandingSection()),
          const SizedBox(width: 48),
          // Cột phải: Form
          Expanded(child: _buildFormCard()),
        ],
      ),
    );
  }

  // ─── Layout 1 cột (Mobile) ─────────────────────────────────────────────────

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildFormCard(),
        const SizedBox(height: 32),
        Text(
          'ETHEREAL SANCTUARY • LUMIERE STAY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: kOnSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ─── Branding Section (cột trái, chỉ hiện trên desktop) ───────────────────

  Widget _buildBrandingSection() {
    return Padding(
      padding: const EdgeInsets.only(right: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tagline nhỏ
          Text(
            'ETHEREAL SANCTUARY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: kOnPrimaryFixedVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Headline lớn
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -1,
                color: kOnSurface,
              ),
              children: [
                const TextSpan(text: 'Lumiere\n'),
                WidgetSpan(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [kPrimary, kPrimaryDim],
                    ).createShader(bounds),
                    child: const Text(
                      'Stay',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: Colors.white, // bị ShaderMask override
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mô tả
          const Text(
            'Kiến tạo không gian quản lý nhà trọ hiện đại, tinh tế và minh bạch. Bắt đầu hành trình chuyển đổi số của bạn ngay hôm nay.',
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: kOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),

          // Feature cards (2 cột)
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.speed_rounded,
                  title: 'Nhanh chóng',
                  desc: 'Tối ưu hóa quy trình vận hành chỉ trong vài lần chạm.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.verified_user_outlined,
                  title: 'An toàn',
                  desc: 'Bảo mật dữ liệu cư dân theo tiêu chuẩn cao nhất.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 16,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: kPrimary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: kOnSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form Card (glass panel) ───────────────────────────────────────────────

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 448),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 24,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: kOnSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Chào mừng bạn đến với hệ thống quản lý Lumiere',
                style: TextStyle(fontSize: 13, color: kOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Fields
              _buildLabeledField(
                label: 'HỌ TÊN',
                controller: _nameController,
                hint: 'Nguyễn Văn A',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                errorText: _submitted ? _nameError : null,
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'SỐ ĐIỆN THOẠI',
                controller: _phoneController,
                hint: '0901 234 567',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                errorText: _submitted ? _phoneError : null,
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'EMAIL',
                controller: _emailController,
                hint: 'lumiere@gmail.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: _submitted ? _emailError : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'MẬT KHẨU',
                controller: _passwordController,
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                errorText: _submitted ? _passwordError : null,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'NHẬP LẠI MẬT KHẨU',
                controller: _confirmController,
                icon: Icons.verified_outlined,
                obscure: _obscureConfirm,
                errorText: _submitted ? _confirmError : null,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 20),

              // Checkbox điều khoản
              _buildTermsCheckbox(),
              const SizedBox(height: 24),

              // Nút đăng ký
              _buildRegisterButton(),
              const SizedBox(height: 24),

              // Footer link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản?',
                    style: TextStyle(fontSize: 13, color: kOnSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đăng nhập ngay',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input Helpers ─────────────────────────────────────────────────────────

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: kOnSurfaceVariant,
            ),
          ),
        ),
        _buildNeumorphicInput(
          controller: controller,
          hint: hint,
          prefixIcon: icon,
          keyboardType: keyboardType,
          hasError: hasError,
        ),
        _buildFieldError(errorText),
      ],
    );
  }

  Widget _buildNeumorphicInput({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    bool hasError = false,
  }) {
    final borderColor = hasError ? Colors.red.shade700 : kPrimaryFixedDim;

    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(9999),
        border: hasError
            ? Border.all(color: Colors.red.shade700, width: 1.5)
            : null,
        boxShadow: [
          // inset shadow mô phỏng neumorphic-inset
          BoxShadow(
            color: kOnSurfaceVariant.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(4, 4),
            // Flutter không hỗ trợ inset shadow natively
            // Dùng kỹ thuật: outer shadow + fill đậm hơn
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: (_) => _refreshSubmittedErrors(),
        style: const TextStyle(fontSize: 14, color: kOnSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kOutlineVariant, fontSize: 14),
          prefixIcon: Icon(
            prefixIcon,
            color: hasError ? Colors.red.shade700 : kOutline,
            size: 20,
          ),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: kOnSurfaceVariant,
            ),
          ),
        ),
        _buildNeumorphicInput(
          controller: controller,
          hint: '••••••••',
          prefixIcon: icon,
          obscure: obscure,
          hasError: hasError,
          suffix: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: hasError ? Colors.red.shade700 : kOutline,
              size: 20,
            ),
          ),
        ),
        _buildFieldError(errorText),
      ],
    );
  }

  Widget _buildFieldError(String? errorText) {
    if (errorText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade700,
            size: 15,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Terms Checkbox ────────────────────────────────────────────────────────

  Widget _buildTermsCheckbox() {
    final errorText = _submitted ? _termsError : null;
    final hasError = errorText != null;

    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom checkbox với animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _agreedToTerms ? kPrimary : kSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(5),
                  border: hasError
                      ? Border.all(color: Colors.red.shade700, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: kOnSurfaceVariant.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(3, 3),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 6,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
                child: _agreedToTerms
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Label với link
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: kOnSurfaceVariant,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Tôi đồng ý với '),
                      TextSpan(
                        text: 'Điều khoản dịch vụ',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' và '),
                      TextSpan(
                        text: 'Chính sách bảo mật',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFieldError(errorText),
        ],
      ),
    );
  }

  // ─── Register Button ───────────────────────────────────────────────────────

  Widget _buildRegisterButton() {
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
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kOnPrimaryFixed),
                  ),
                )
              : const Text(
                  'Đăng ký',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kOnPrimaryFixed,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() => _submitted = true);
    if (!_isFormValid) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);
    try {
      await AuthService.registerWithEmail(
        fullName: name,
        email: email,
        password: password,
        phone: phone.isNotEmpty ? phone : null,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email này đã được sử dụng.';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        default:
          message = 'Đăng ký thất bại: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Floating Status Pill ──────────────────────────────────────────────────

  Widget _buildFloatingStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút help tròn
        _buildGlassPill(
          child: const Icon(
            Icons.help_outline_rounded,
            color: kPrimary,
            size: 20,
          ),
          size: 48,
          isCircle: true,
        ),
        const SizedBox(width: 12),

        // Status badge
        _buildGlassPill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Đèn xanh nhấp nháy
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (_, value, child) =>
                    Opacity(opacity: value, child: child),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399), // emerald-400
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'HỆ THỐNG ỔN ĐỊNH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: kOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassPill({
    required Widget child,
    double? size,
    bool isCircle = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isCircle ? 9999 : 9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: size,
          height: size,
          padding: size == null
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
              : null,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
