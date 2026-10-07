import '../state/display_preferences.dart' as ui;
import 'preferences_store.dart' as prefs;

void applyStoreToDisplayPreferences(
  prefs.PreferencesStore store,
  ui.DisplayPreferences display,
) {
  final sort = switch (store.defaultSort) {
    prefs.EventSortOrder.title => ui.EventSortCriterion.title,
    prefs.EventSortOrder.date => ui.EventSortCriterion.date,
    prefs.EventSortOrder.popularity => ui.EventSortCriterion.remainingPlaces,
  };
  display.setSortCriterion(sort);

  final filter = store.defaultCategoryFilter;
  display.setCategoryFilter(filter.isEmpty ? null : filter);

  final density = switch (store.displayDensity) {
    prefs.DisplayDensity.compact => ui.DisplayDensity.compact,
    prefs.DisplayDensity.comfortable => ui.DisplayDensity.comfortable,
  };
  display.setDensity(density);
}
