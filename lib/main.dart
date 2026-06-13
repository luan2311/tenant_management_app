import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/firebase_options.dart';
import 'package:tenant_management_app/theme/app_theme.dart';
import 'package:tenant_management_app/services/auth_service.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'package:tenant_management_app/views/auth/login_screen.dart';
import 'package:tenant_management_app/views/tenant_shell.dart';
import 'package:tenant_management_app/views/admin/admin_main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        routes: {'/home': (_) => const TenantShell()},
        home: const _SessionGate(),
      ),
    );
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kSurface,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return _RoleGate(firebaseUid: user.uid);
      },
    );
  }
}

class _RoleGate extends StatefulWidget {
  const _RoleGate({required this.firebaseUid});

  final String firebaseUid;

  @override
  State<_RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<_RoleGate> {
  late Future<void> _loadProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileFuture = context.read<AppState>().checkAutoLogin();
  }

  @override
  void didUpdateWidget(covariant _RoleGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firebaseUid != widget.firebaseUid) {
      _loadProfileFuture = context.read<AppState>().checkAutoLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kSurface,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = context.watch<AppState>().currentUser;
        if (currentUser == null) {
          return const LoginScreen();
        }

        return currentUser.role == 'admin'
            ? const AdminMainLayout()
            : const TenantShell();
      },
    );
  }
}
