/// Clés de préférences déclarées une seule fois. Toute autre partie du code
/// référence ces constantes : aucune chaîne littérale de clé ailleurs.
class PreferenceKeys {
  const PreferenceKeys._();

  /// défaut : 'light'
  static const String themeMode = 'pref_theme_mode';
  /// défaut : 'date'
  static const String defaultSort = 'pref_default_sort';
  /// défaut : '' (aucun filtre)
  static const String defaultCategoryFilter = 'pref_default_category';
  /// défaut : 'comfortable'
  static const String displayDensity = 'pref_display_density';
  /// défaut : 'home'
  static const String lastScreen = 'pref_last_screen';

  static const Set<String> all = {
    themeMode,
    defaultSort,
    defaultCategoryFilter,
    displayDensity,
    lastScreen,
  };
}
