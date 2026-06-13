import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/styles.dart';
import '../service/app_state.dart';
import 'admin/admin_main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final appState = context.read<AppState>();
      final success = await appState.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        final role = appState.currentUser?.role;
        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminMainLayout()),
          );
        } else {
          // Tenant module - simple placeholder or mock screen since this is Huy & Khanh's sprint
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Tenant Portal'),
                  backgroundColor: AppColors.sanctuaryDark,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        appState.logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: GlassmorphicContainer(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.house, size: 64, color: AppColors.sanctuaryDark),
                          const SizedBox(height: 16),
                          Text(
                            'Xin chào, ${appState.currentUser?.fullName}!',
                            style: AppStyles.title(context, color: AppColors.sanctuaryDark, fontSize: 20),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Phân hệ Khách Thuê (Tenant) đang phát triển bởi Huy và Khánh. Vui lòng đăng nhập bằng tài khoản "admin" (mật khẩu: "admin123") để kiểm thử 3 Sprints của Luân.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Tên đăng nhập hoặc mật khẩu không chính xác.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;

    return Scaffold(
      body: EtherealBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand / Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppStyles.glassmorphic(opacity: 0.84, borderRadius: 22),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 42,
                        color: AppColors.sanctuaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LUMIERE STAY',
                      style: AppStyles.headline(
                        context,
                        color: AppColors.sanctuaryDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      'The Ethereal Sanctuary',
                      style: AppStyles.caption(
                        context,
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login Card
                    GlassmorphicContainer(
                      borderRadius: 26,
                      opacity: 0.78,
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Chào mừng trở lại',
                            style: AppStyles.title(
                              context,
                              color: AppColors.sanctuaryDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng đăng nhập để tiếp tục quản lý',
                            style: AppStyles.caption(context, fontSize: 13),
                          ),
                          const SizedBox(height: 24),
                          
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: AppStyles.caption(context, color: Colors.red.shade900),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Tên đăng nhập',
                              labelStyle: GoogleFonts.beVietnamPro(color: AppColors.textSecondary),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.sanctuaryDark),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.58),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.70)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.sanctuaryDark, width: 1.5),
                              ),
                            ),
                            style: GoogleFonts.beVietnamPro(color: AppColors.textPrimary),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên đăng nhập';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: GoogleFonts.beVietnamPro(color: AppColors.textSecondary),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.sanctuaryDark),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.sanctuaryDark,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.58),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.70)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.sanctuaryDark, width: 1.5),
                              ),
                            ),
                            style: GoogleFonts.beVietnamPro(color: AppColors.textPrimary),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Quên mật khẩu
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tính năng quên mật khẩu đang phát triển')),
                                );
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: AppStyles.caption(
                                  context,
                                  color: AppColors.sanctuaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login button
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sanctuaryDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Đăng nhập',
                                    style: AppStyles.body(
                                      context,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Direct quick account access hint (for testability)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppStyles.glassmorphic(opacity: 0.48, borderRadius: 16),
                      child: Column(
                        children: [
                          Text(
                            'Tài khoản kiểm thử:',
                            style: AppStyles.caption(context, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Admin: admin / admin123',
                            style: AppStyles.caption(context),
                          ),
                          Text(
                            'Tenant: huytenant / tenant123',
                            style: AppStyles.caption(context),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
