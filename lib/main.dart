import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/views/admin/admin_main_layout.dart';
import 'package:tenant_management_app/views/auth/login_screen.dart';
import 'package:tenant_management_app/views/tenant_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LumiereStayApp());
}

class LumiereStayApp extends StatelessWidget {
  const LumiereStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Lumiere Stay',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routes: {
          '/home': (_) => const TenantShell(),
        },
        home: const _SessionGate(),
      ),
    );
  }
}

/// Kiem tra phien SQLite khi khoi dong.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  late final Future<void> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = context.read<AppState>().checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: kSurface,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = context.watch<AppState>().currentUser;
        if (currentUser == null) return const LoginScreen();
        return currentUser.role == 'admin'
            ? const AdminMainLayout()
            : const TenantShell();
      },
    );
  }
}
