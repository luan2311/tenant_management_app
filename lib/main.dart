import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/styles.dart';
import 'service/app_state.dart';
import 'view/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Lumiere Stay',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.backgroundStart,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.sanctuaryDark,
            primary: AppColors.sanctuaryDark,
            secondary: AppColors.accent,
            background: AppColors.sanctuaryLight,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white.withOpacity(0.54),
            selectedColor: AppColors.sanctuaryDark,
            side: BorderSide(color: Colors.white.withOpacity(0.6)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Be Vietnam Pro',
              ),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
