import 'package:event_hub/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'auth_screens/login.dart';
import 'nav_bar.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Cloud Messaging
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('✅ FCM initialized successfully');
  } catch (e) {
    print('⚠️ FCM initialization failed: $e');
    // Continue app execution even if FCM fails
  }

  // Try auto-login if Remember Me was enabled
  // This will be handled by the AuthService
  // The authStateProvider will automatically update if login succeeds

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF5B4EFF),
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF5B4EFF),
          secondary: const Color(0xFF00D9A5),
          surface: Colors.white,
          error: const Color(0xFFFF6B6B),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF5B4EFF),
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5B4EFF),
          secondary: const Color(0xFF00D9A5),
          surface: const Color(0xFF1E1E1E),
          error: const Color(0xFFFF6B6B),
        ),
      ),
      home: authState.when(
        data: (user) {
          // If user is logged in, show main navigation
          // Otherwise show login screen
          return user != null ? const MainNavigation() : const SignInScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5B4EFF),
            ),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}