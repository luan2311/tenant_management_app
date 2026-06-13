import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tenant_management_app/firebase_options.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/services/auth_service.dart';
import 'package:tenant_management_app/views/auth/login_screen.dart';
import 'package:tenant_management_app/views/tenant_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LumiereStayApp());
}

class LumiereStayApp extends StatelessWidget {
  const LumiereStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumiere Stay',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routes: {
        '/home': (_) => const TenantShell(),
      },
      home: const _SessionGate(),
    );
  }
}

/// Lắng nghe trạng thái xác thực Firebase theo thời gian thực:
/// - Đã đăng nhập → TenantShell
/// - Chưa đăng nhập → LoginScreen
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        // Đang tải trạng thái xác thực
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kSurface,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Đã đăng nhập → TenantShell, chưa → LoginScreen
        return snapshot.hasData ? const TenantShell() : const LoginScreen();
      },
    );
  }
}
