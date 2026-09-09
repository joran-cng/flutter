import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Event Planner affiche le mur d\'événements', (tester) async {
    await tester.pumpWidget(const EventPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Event Planner'), findsOneWidget);
    expect(find.text('Prochains événements'), findsOneWidget);
  });
}
