import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/data/event_repository.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/state/display_preferences.dart';
import 'package:flutter_application_1/state/event_list_state.dart';
import 'package:flutter_application_1/state/registration_cart.dart';

void main() {
  testWidgets('Event Planner affiche l\'écran d\'accueil', (tester) async {
    await tester.pumpWidget(
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Event Planner'), findsOneWidget);
  });
}
