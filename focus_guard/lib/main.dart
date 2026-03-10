import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/services/task_provider.dart';
import 'core/services/native_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/blocking/screens/blocked_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Native Service
  NativeService.initialize();

  // Supabase Configuration
  await Supabase.initialize(
    url: 'https://pkxdvdjdkjdciihouvpm.supabase.co',
    anonKey: 'sb_publishable_Rg9kBBJPHajZpMhVrAbiyQ_CJN5yJ6S',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const FocusGuardApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FocusGuardApp extends StatefulWidget {
  const FocusGuardApp({super.key});

  @override
  State<FocusGuardApp> createState() => _FocusGuardAppState();
}

class _FocusGuardAppState extends State<FocusGuardApp> {
  @override
  void initState() {
    super.initState();
    NativeService.onBlocked.listen((_) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BlockedScreen()),
        (route) => false // Remove all previous routes so back button doesn't work easily
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'FocusGuard',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
