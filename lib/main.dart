import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/staff/staff_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  final initialDark = await ThemeProvider.loadInitialTheme();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),

        // State Providers
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialDark),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<AuthService>()),
        ),
        ChangeNotifierProvider<IncidentProvider>(
          create: (ctx) => IncidentProvider(
            ctx.read<FirestoreService>(),
            ctx.read<StorageService>(),
          ),
        ),
      ],
      child: const CampusCareApp(),
    ),
  );
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALU CampusCare',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Only display full-screen loading on initial app launch bootstrap
    if (authProvider.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(radius: 14),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Require verified email address to prevent unverified domain spoofing
    if (!authProvider.isEmailVerified) {
      return const VerifyEmailScreen();
    }

    // Role-based routing
    if (authProvider.isStaff) {
      return const StaffDashboardScreen();
    } else {
      return const StudentHomeScreen();
    }
  }
}
