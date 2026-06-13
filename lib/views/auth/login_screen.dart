import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _submitted = false;
  String? _customPasswordError;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    if (_customPasswordError != null) return _customPasswordError;
    return null;
  }

  bool get _isFormValid => _emailError == null && _passwordError == null;

  void _refreshSubmittedErrors() {
    if (_submitted) setState(() {});
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
                      const SizedBox(height: 32),
                      _buildLoginCard(),
                      const SizedBox(height: 40),
                      _buildFooterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(bottom: 24, right: 24, child: _buildHelpButton()),
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
          colors: [Color(0xFFDCEFF9), Color(0xFFF7F9FB), Color(0xFFEFF5FA)],
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
              _buildInputLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'lumiere@gmail.com',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: _submitted ? _emailError : null,
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
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
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
              _buildPasswordField(
                errorText: _submitted ? _passwordError : null,
              ),
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
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => _refreshSubmittedErrors(),
          style: const TextStyle(fontSize: 15, color: kOnSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: kOutline.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: hasError ? Colors.red.shade700 : kOutline,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.55),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red.shade700
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red.shade700
                    : Colors.white.withValues(alpha: 0.45),
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade700 : kPrimaryFixed,
                width: 2,
              ),
            ),
          ),
        ),
        _buildFieldError(errorText),
      ],
    );
  }

  Widget _buildPasswordField({String? errorText}) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (_) {
            if (_customPasswordError != null) {
              setState(() {
                _customPasswordError = null;
              });
            }
            _refreshSubmittedErrors();
          },
          style: const TextStyle(fontSize: 15, color: kOnSurface),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: kOutline.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: hasError ? Colors.red.shade700 : kOutline,
              size: 22,
            ),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: hasError ? Colors.red.shade700 : kOutline,
                size: 22,
              ),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.55),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red.shade700
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red.shade700
                    : Colors.white.withValues(alpha: 0.45),
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade700 : kPrimaryFixed,
                width: 2,
              ),
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
      padding: const EdgeInsets.only(top: 6),
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
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: kOnPrimaryFixed,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _submitted = true;
      _customPasswordError = null;
    });
    if (!_isFormValid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithEmail(email, password);
      // _SessionGate trong main.dart tự route theo role (admin/tenant)
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Sai mật khẩu. Vui lòng thử lại.';
          setState(() {
            _customPasswordError = 'Mật khẩu không chính xác.';
          });
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa.';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều lần thử. Vui lòng thử lại sau.';
          break;
        case 'network-request-failed':
          message = 'Lỗi mạng. Kiểm tra kết nối internet của thiết bị.';
          break;
        default:
          message = 'Đăng nhập thất bại: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: const _GoogleLogo(size: 22),
        label: const Text(
          'Đăng nhập bằng Google',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: kOnSurface,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.signInWithGoogle();
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      // _SessionGate trong main.dart tự route theo role (admin/tenant)
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập Google thất bại: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập Google thất bại. Vui lòng thử lại.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: kPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _paths = [
    _GoogleLogoPath(
      color: Color(0xFF4285F4),
      data:
          'M17.64 9.20455C17.64 8.56637 17.5827 7.95273 17.4764 7.36364H9V10.845H13.8436C13.635 11.97 13.0009 12.9232 12.0477 13.5614V15.8195H14.9564C16.6582 14.3768 17.64 12.2523 17.64 9.20455Z',
    ),
    _GoogleLogoPath(
      color: Color(0xFF34A853),
      data:
          'M9 18C11.43 18 13.4673 17.1941 14.9564 15.8195L12.0477 13.5614C11.2418 14.1014 10.2109 14.4205 9 14.4205C6.65591 14.4205 4.67182 12.8373 3.96409 10.71H0.957275V13.0418C2.43818 15.9832 5.48182 18 9 18Z',
    ),
    _GoogleLogoPath(
      color: Color(0xFFFBBC05),
      data:
          'M3.96409 10.71C3.78409 10.17 3.68182 9.59318 3.68182 9C3.68182 8.40682 3.78409 7.83 3.96409 7.29V4.95818H0.957273C0.347727 6.17318 0 7.54773 0 9C0 10.4523 0.347727 11.8268 0.957273 13.0418L3.96409 10.71Z',
    ),
    _GoogleLogoPath(
      color: Color(0xFFEA4335),
      data:
          'M9 3.57955C10.3214 3.57955 11.5077 4.03364 12.4405 4.92545L15.0218 2.34409C13.4632 0.891818 11.4259 0 9 0C5.48182 0 2.43818 2.01682 0.957275 4.95818L3.96409 7.29C4.67182 5.16273 6.65591 3.57955 9 3.57955Z',
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 18;
    canvas.save();
    canvas.translate(
      (size.width - size.shortestSide) / 2,
      (size.height - size.shortestSide) / 2,
    );
    canvas.scale(scale);

    for (final logoPath in _paths) {
      canvas.drawPath(
        logoPath.path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = logoPath.color,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleLogoPath {
  const _GoogleLogoPath({required this.color, required this.data});

  final Color color;
  final String data;

  Path get path => _SvgPathParser(data).parse();
}

class _SvgPathParser {
  _SvgPathParser(String data) : _tokens = _tokenize(data);

  final List<String> _tokens;
  int _index = 0;
  String? _command;
  double _x = 0;
  double _y = 0;

  Path parse() {
    final path = Path();
    while (_index < _tokens.length) {
      final token = _tokens[_index];
      if (_isCommand(token)) {
        _command = token;
        _index++;
      }

      switch (_command) {
        case 'M':
          _x = _number();
          _y = _number();
          path.moveTo(_x, _y);
          _command = 'L';
          break;
        case 'L':
          _x = _number();
          _y = _number();
          path.lineTo(_x, _y);
          break;
        case 'H':
          _x = _number();
          path.lineTo(_x, _y);
          break;
        case 'V':
          _y = _number();
          path.lineTo(_x, _y);
          break;
        case 'C':
          final x1 = _number();
          final y1 = _number();
          final x2 = _number();
          final y2 = _number();
          _x = _number();
          _y = _number();
          path.cubicTo(x1, y1, x2, y2, _x, _y);
          break;
        case 'Z':
        case 'z':
          path.close();
          _command = null;
          break;
        default:
          throw FormatException('Unsupported SVG command: $_command');
      }
    }
    return path;
  }

  double _number() => double.parse(_tokens[_index++]);

  static bool _isCommand(String token) => RegExp(r'^[A-Za-z]$').hasMatch(token);

  static List<String> _tokenize(String data) {
    final matches = RegExp(
      r'[A-Za-z]|[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?',
    ).allMatches(data);
    return matches.map((match) => match.group(0)!).toList();
  }
}
