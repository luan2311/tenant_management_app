import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tenant_management_app/services/auth_service.dart';

// ─── Forgot Password Screen ───────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Nền + orbs
          _buildBackground(),

          // Layer 2: Floating card trang trí (chỉ hiện trên desktop)
          if (isWide) _buildDecorativeCard(),

          // Layer 3: Nội dung chính
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    children: [
                      // Brand header
                      _buildBrandHeader(),
                      const SizedBox(height: 40),

                      // Card quên mật khẩu
                      _buildForgotCard(),
                      const SizedBox(height: 48),

                      // Security badge
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

  // ─── Background ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
      ),
      child: Stack(
        children: [
          // Orb trên trái (primary-fixed/20)
          Positioned(
            top: -80,
            left: -80,
            child: _blurOrb(
              MediaQuery.of(context).size.width * 0.45,
              kPrimaryFixed.withOpacity(0.20),
              100,
            ),
          ),
          // Orb dưới phải (tertiary-fixed/20)
          Positioned(
            bottom: -100,
            right: -100,
            child: _blurOrb(
              MediaQuery.of(context).size.width * 0.55,
              kTertiaryFixed.withOpacity(0.20),
              100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb(double size, Color color, double blur) {
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

  // ─── Decorative tilted card (desktop) ────────────────────────────────────────
  // Tương ứng: div.hidden.lg:block.absolute.right-[5%].top-[25%].-rotate-6

  Widget _buildDecorativeCard() {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.05,
      top: MediaQuery.of(context).size.height * 0.25,
      child: Transform.rotate(
        angle: -0.105, // -6 độ tính bằng radian
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              width: 256,
              height: 320,
              decoration: BoxDecoration(
                color: kSurfaceContainerHigh.withOpacity(0.30),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kOnSurfaceVariant.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(8, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 16,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              // Gradient placeholder thay cho ảnh (tránh load mạng)
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFDCEFF9),
                      Color(0xFFEEEEFD),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Brand Header ─────────────────────────────────────────────────────────────

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Icon shield với gradient
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
                color: kOnSurfaceVariant.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 16,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_rounded, // shield_lock → Icons.shield_rounded
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),

        // Tên app với gradient text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimary, kOnPrimaryFixedVariant],
          ).createShader(bounds),
          child: const Text(
            'Ethereal Sanctuary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: Colors.white, // bị ShaderMask override
            ),
          ),
        ),
      ],
    );
  }

  // ─── Forgot Password Card ─────────────────────────────────────────────────────

  Widget _buildForgotCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: kOnSurfaceVariant.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 16,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Tiêu đề
              const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: kOnSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhập email của bạn để nhận mã khôi phục',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kOnSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Label
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'ĐỊA CHỈ EMAIL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: kOnSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Email input (neumorphic style)
              _buildEmailField(),
              const SizedBox(height: 24),

              // Nút gửi
              _buildSubmitButton(),
              const SizedBox(height: 40),

              // Link quay lại đăng nhập
              _buildBackLink(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Email Field ──────────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: kSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        // Mô phỏng neumorphic-inset bằng double outer shadow
        boxShadow: [
          BoxShadow(
            color: kOnSurfaceVariant.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.85),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 14, color: kOnSurface),
        decoration: InputDecoration(
          hintText: 'example@email.com',
          hintStyle: TextStyle(color: kOutlineVariant, fontSize: 14),
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: kOutlineVariant,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryFixed, width: 2),
          ),
        ),
      ),
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
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
              color: kPrimary.withOpacity(0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kOnPrimary),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gửi mã xác nhận',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kOnPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: kOnPrimary, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư.'),
          duration: Duration(seconds: 4),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        default:
          message = 'Gửi email thất bại: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi email thất bại. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Back Link ────────────────────────────────────────────────────────────────

  Widget _buildBackLink() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_rounded, color: kPrimary, size: 18),
          SizedBox(width: 6),
          Text(
            'Quay lại Đăng nhập',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Security Badge ───────────────────────────────────────────────────────────

  Widget _buildSecurityBadge() {
    return Opacity(
      opacity: 0.40,
      child: ColorFiltered(
        // grayscale effect bằng ColorFilter matrix
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadgeItem(
              icon: Icons.verified_user_outlined,
              label: 'SECURE ACCESS',
            ),
            // Dấu chấm ngăn cách
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kOnSurfaceVariant,
              ),
            ),
            _buildBadgeItem(
              icon: Icons.lock_outlined,
              label: 'SSL PROTECTED',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: kOnSurface, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: kOnSurface,
          ),
        ),
      ],
    );
  }
}