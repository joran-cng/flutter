import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/storage/preferences_store.dart';

class FakePreferencesStore implements PreferencesStore {
  AppThemeMode _theme = AppThemeMode.light;
  EventSortOrder _sort = EventSortOrder.date;
  String _category = '';
  DisplayDensity _density = DisplayDensity.comfortable;
  String _lastScreen = 'home';

  @override
  Future<void> init() async {}

  @override
  AppThemeMode get themeMode => _theme;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _theme = mode;
  }

  @override
  EventSortOrder get defaultSort => _sort;

  @override
  Future<void> setDefaultSort(EventSortOrder order) async {
    _sort = order;
  }

  @override
  String get defaultCategoryFilter => _category;

  @override
  Future<void> setDefaultCategoryFilter(String category) async {
    _category = category;
  }

  @override
  DisplayDensity get displayDensity => _density;

  @override
  Future<void> setDisplayDensity(DisplayDensity density) async {
    _density = density;
  }

  @override
  String get lastScreen => _lastScreen;

  @override
  Future<void> setLastScreen(String screenName) async {
    _lastScreen = screenName;
  }

  @override
  Future<void> resetToDefaults() async {
    _theme = AppThemeMode.light;
    _sort = EventSortOrder.date;
    _category = '';
    _density = DisplayDensity.comfortable;
    _lastScreen = 'home';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Event Planner affiche l\'écran d\'accueil', (tester) async {
    final preferencesStore = FakePreferencesStore();
    await preferencesStore.init();

    await tester.pumpWidget(
      EventPlannerRoot(preferencesStore: preferencesStore),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Event Planner'), findsOneWidget);
  });
}
