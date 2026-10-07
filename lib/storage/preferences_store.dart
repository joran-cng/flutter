import 'package:shared_preferences/shared_preferences.dart';

import 'preference_keys.dart';

enum AppThemeMode { light, dark }

enum EventSortOrder { date, title, popularity }

enum DisplayDensity { comfortable, compact }

abstract class PreferencesStore {
  Future<void> init();

  AppThemeMode get themeMode;
  Future<void> setThemeMode(AppThemeMode mode);

  EventSortOrder get defaultSort;
  Future<void> setDefaultSort(EventSortOrder order);

  String get defaultCategoryFilter;
  Future<void> setDefaultCategoryFilter(String category);

  DisplayDensity get displayDensity;
  Future<void> setDisplayDensity(DisplayDensity density);

  String get lastScreen;
  Future<void> setLastScreen(String screenName);

  Future<void> resetToDefaults();
}

class SharedPreferencesStore implements PreferencesStore {
  late SharedPreferencesWithCache _cache;
  bool _initialized = false;

  @override
  Future<void> init() async {
    _cache = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: PreferenceKeys.all,
      ),
    );
    _initialized = true;
  }

  void _ensureInit() {
    if (!_initialized) {
      throw StateError('PreferencesStore.init() must complete before use.');
    }
  }

  @override
  AppThemeMode get themeMode {
    _ensureInit();
    final raw = _cache.getString(PreferenceKeys.themeMode) ?? 'light';
    return raw == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _ensureInit();
    await _cache.setString(
      PreferenceKeys.themeMode,
      mode == AppThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  EventSortOrder get defaultSort {
    _ensureInit();
    return switch (_cache.getString(PreferenceKeys.defaultSort) ?? 'date') {
      'title' => EventSortOrder.title,
      'popularity' => EventSortOrder.popularity,
      _ => EventSortOrder.date,
    };
  }

  @override
  Future<void> setDefaultSort(EventSortOrder order) async {
    _ensureInit();
    final value = switch (order) {
      EventSortOrder.date => 'date',
      EventSortOrder.title => 'title',
      EventSortOrder.popularity => 'popularity',
    };
    await _cache.setString(PreferenceKeys.defaultSort, value);
  }

  @override
  String get defaultCategoryFilter {
    _ensureInit();
    return _cache.getString(PreferenceKeys.defaultCategoryFilter) ?? '';
  }

  @override
  Future<void> setDefaultCategoryFilter(String category) async {
    _ensureInit();
    await _cache.setString(PreferenceKeys.defaultCategoryFilter, category);
  }

  @override
  DisplayDensity get displayDensity {
    _ensureInit();
    final raw = _cache.getString(PreferenceKeys.displayDensity) ?? 'comfortable';
    return raw == 'compact' ? DisplayDensity.compact : DisplayDensity.comfortable;
  }

  @override
  Future<void> setDisplayDensity(DisplayDensity density) async {
    _ensureInit();
    await _cache.setString(
      PreferenceKeys.displayDensity,
      density == DisplayDensity.compact ? 'compact' : 'comfortable',
    );
  }

  @override
  String get lastScreen {
    _ensureInit();
    return _cache.getString(PreferenceKeys.lastScreen) ?? 'home';
  }

  @override
  Future<void> setLastScreen(String screenName) async {
    _ensureInit();
    await _cache.setString(PreferenceKeys.lastScreen, screenName);
  }

  @override
  Future<void> resetToDefaults() async {
    _ensureInit();
    await setThemeMode(AppThemeMode.light);
    await setDefaultSort(EventSortOrder.date);
    await setDefaultCategoryFilter('');
    await setDisplayDensity(DisplayDensity.comfortable);
    await setLastScreen('home');
  }
}
