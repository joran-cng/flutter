import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/event_repository.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'screens/main_shell.dart';
import 'state/display_preferences.dart';
import 'state/event_list_state.dart';
import 'state/registration_cart.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<EventRepository>(create: (_) => const EventRepository()),
        ChangeNotifierProvider(create: (_) => DisplayPreferences()),
        ChangeNotifierProxyProvider<EventRepository, RegistrationCart>(
          create: (context) => RegistrationCart(
            repository: context.read<EventRepository>(),
          ),
          update: (context, repository, previousCart) =>
              previousCart!..updateRepository(repository),
        ),
        ChangeNotifierProxyProvider<EventRepository, EventListNotifier>(
          create: (context) => EventListNotifier(
            repository: context.read<EventRepository>(),
          ),
          update: (context, repository, previousNotifier) {
            previousNotifier!.updateRepository(repository);
            return previousNotifier;
          },
        ),
      ],
      child: const EventPlannerApp(),
    ),
  );
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
        final repository = context.read<EventRepository>();
        if (settings.name == AppRoutes.home || settings.name == null) {
          return MaterialPageRoute<void>(
            settings: const RouteSettings(name: AppRoutes.home),
            builder: (_) => const MainShell(),
          );
        }
        return RouteGenerator.onGenerateRoute(settings, repository);
      },
      onUnknownRoute: RouteGenerator.onUnknownRoute,
    );
  }
}
