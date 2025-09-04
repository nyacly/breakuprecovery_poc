import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:breakup_recovery/theme.dart';
import 'package:breakup_recovery/screens/onboarding_screen.dart';
import 'package:breakup_recovery/screens/main_navigation_screen.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BreakupRecoveryApp());
}

class BreakupRecoveryApp extends StatelessWidget {
  const BreakupRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breakup Recovery',
      debugShowCheckedModeBanner: false,
      theme: calmingLightTheme,
      darkTheme: calmingLightTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: BRColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [BRColors.primaryGradientStart, BRColors.primaryGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(BRRadius.standard),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: BRSpacing.lg),
                  const CircularProgressIndicator(),
                  const SizedBox(height: BRSpacing.md),
                  Text(
                    'Loading your recovery journey...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: BRColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const UserInitializationWrapper();
        }

        return const OnboardingScreen();
      },
    );
  }
}

class UserInitializationWrapper extends StatelessWidget {
  const UserInitializationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkUserInitialization(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: BRColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [BRColors.primaryGradientStart, BRColors.primaryGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(BRRadius.standard),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: BRSpacing.lg),
                  const CircularProgressIndicator(),
                  const SizedBox(height: BRSpacing.md),
                  Text(
                    'Setting up your recovery plan...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: BRColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // User is initialized, go to main app
        return const MainNavigationScreen();
      },
    );
  }

  Future<bool> _checkUserInitialization() async {
    try {
      final repository = BreakupRecoveryRepository();
      await repository.initializeNewUser();
      return true;
    } catch (e) {
      // Log error in production
      print('User initialization error: $e');
      return true; // Continue to app even if initialization fails
    }
  }
}
