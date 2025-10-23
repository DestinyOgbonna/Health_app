import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_dashboard/helpers/theming/theme.dart';
import 'package:health_dashboard/helpers/theming/theme_provider.dart';
import 'package:health_dashboard/presentations/dashboard/data/dashboard_provider.dart';
import 'package:health_dashboard/presentations/dashboard/presentation/dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const HealthApp(),
    ),
  );
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardState>(
          create: (context) => DashboardState(),
        ),
      ],
      child: const BiometricsDashboardApp(),
    );
  }
}

class BiometricsDashboardApp extends StatelessWidget {
  const BiometricsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardState>(
          create: (context) => DashboardState()..loadData(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp(
          title: 'Biometrics Dashboard',
          theme: Provider.of<ThemeProvider>(context).themeData,
          darkTheme: darkMode,
          debugShowCheckedModeBanner: false,
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
