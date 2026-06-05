import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'views/Login_screen.dart';
import 'views/tenant_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

/// Kiểm tra phiên SharedPreferences khi khởi động:
/// - Đã đăng nhập → TenantShell
/// - Chưa đăng nhập → LoginScreen
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: kSurface,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const TenantShell() : const LoginScreen();
      },
    );
  }
}
