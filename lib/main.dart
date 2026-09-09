import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const EventPlannerApp());
}

class EventPlannerApp extends StatelessWidget {
  const EventPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.home || settings.name == null) {
          return MaterialPageRoute<void>(
            settings: const RouteSettings(name: AppRoutes.home),
            builder: (_) => const MainShell(),
          );
        }
        return RouteGenerator.onGenerateRoute(settings);
      },
      onUnknownRoute: RouteGenerator.onUnknownRoute,
    );
  }
}
