import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/event_repository.dart';
import 'firebase_options.dart';
import 'screens/firebase_init_error_screen.dart';
import 'services/auth_gate.dart';
import 'state/display_preferences.dart';
import 'state/event_list_state.dart';
import 'state/registration_cart.dart';
import 'storage/app_preferences_scope.dart';
import 'storage/draft_repository.dart';
import 'storage/preferences_store.dart';
import 'storage/preferences_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {}

  final preferencesStore = SharedPreferencesStore();
  await preferencesStore.init();
  await DraftRepository.instance.init();
  runApp(
    EventPlannerRoot(
      preferencesStore: preferencesStore,
      firebaseReady: firebaseReady,
    ),
  );
}

class EventPlannerRoot extends StatefulWidget {
  const EventPlannerRoot({
    super.key,
    required this.preferencesStore,
    required this.firebaseReady,
  });

  final PreferencesStore preferencesStore;
  final bool firebaseReady;

  @override
  State<EventPlannerRoot> createState() => _EventPlannerRootState();
}

class _EventPlannerRootState extends State<EventPlannerRoot> {
  @override
  Widget build(BuildContext context) {
    return AppPreferencesScope(
      store: widget.preferencesStore,
      onPreferencesChanged: () => setState(() {}),
      child: MultiProvider(
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
        child: _PreferencesBootstrap(
          child: EventPlannerApp(
            preferencesStore: widget.preferencesStore,
            firebaseReady: widget.firebaseReady,
          ),
        ),
      ),
    );
  }
}

class _PreferencesBootstrap extends StatefulWidget {
  const _PreferencesBootstrap({required this.child});

  final Widget child;

  @override
  State<_PreferencesBootstrap> createState() => _PreferencesBootstrapState();
}

class _PreferencesBootstrapState extends State<_PreferencesBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final store = AppPreferencesScope.readStore(context);
      final display = context.read<DisplayPreferences>();
      applyStoreToDisplayPreferences(store, display);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class EventPlannerApp extends StatelessWidget {
  const EventPlannerApp({
    super.key,
    required this.preferencesStore,
    required this.firebaseReady,
  });

  final PreferencesStore preferencesStore;
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    final isDark = preferencesStore.themeMode == AppThemeMode.dark;

    return MaterialApp(
      title: 'Event Planner',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: firebaseReady
          ? const AuthGate()
          : const FirebaseInitErrorScreen(),
    );
  }
}
