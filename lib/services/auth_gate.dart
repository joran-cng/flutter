import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/organizer_home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/reset_password_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static Route<dynamic> _guestRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case AppRoutes.resetPassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ResetPasswordScreen(),
        );
      case AppRoutes.login:
      case Navigator.defaultRouteName:
      case null:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.login),
          builder: (_) => const LoginScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
    }
  }

  static Route<dynamic> _authenticatedRoute(
    User user,
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AppRoutes.profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProfileScreen(user: user),
        );
      case AppRoutes.consumerApp:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainShell(),
        );
      case Navigator.defaultRouteName:
      case AppRoutes.organizerHome:
      case null:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.organizerHome),
          builder: (_) => OrganizerHomeScreen(user: user),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => OrganizerHomeScreen(user: user),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return Navigator(
            key: const ValueKey('guest-nav'),
            initialRoute: AppRoutes.login,
            onGenerateRoute: _guestRoute,
          );
        }

        return Navigator(
          key: ValueKey('user-nav-${user.uid}'),
          initialRoute: AppRoutes.organizerHome,
          onGenerateRoute: (settings) => _authenticatedRoute(user, settings),
        );
      },
    );
  }
}
