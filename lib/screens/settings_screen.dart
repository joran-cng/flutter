import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/display_preferences.dart' hide DisplayDensity;
import '../storage/app_preferences_scope.dart';
import '../storage/preferences_store.dart' as prefs;
import '../storage/preferences_sync.dart';
import '../theme/spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  prefs.PreferencesStore get _store => AppPreferencesScope.readStore(context);

  Future<void> _persist(Future<void> Function() action) async {
    await action();
    if (!mounted) {
      return;
    }
    final display = context.read<DisplayPreferences>();
    applyStoreToDisplayPreferences(_store, display);
    AppPreferencesScope.of(context).onPreferencesChanged();
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          DropdownButtonFormField<prefs.AppThemeMode>(
            initialValue: store.themeMode,
            decoration: const InputDecoration(labelText: 'Thème'),
            items: const [
              DropdownMenuItem(value: prefs.AppThemeMode.light, child: Text('Clair')),
              DropdownMenuItem(value: prefs.AppThemeMode.dark, child: Text('Sombre')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              _persist(() => store.setThemeMode(value));
            },
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<prefs.EventSortOrder>(
            initialValue: store.defaultSort,
            decoration: const InputDecoration(labelText: 'Tri par défaut'),
            items: const [
              DropdownMenuItem(value: prefs.EventSortOrder.date, child: Text('Date')),
              DropdownMenuItem(value: prefs.EventSortOrder.title, child: Text('Titre')),
              DropdownMenuItem(
                value: prefs.EventSortOrder.popularity,
                child: Text('Popularité'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              _persist(() => store.setDefaultSort(value));
            },
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<String>(
            initialValue: store.defaultCategoryFilter.isEmpty
                ? ''
                : store.defaultCategoryFilter,
            decoration: const InputDecoration(labelText: 'Filtre catégorie'),
            items: const [
              DropdownMenuItem(value: '', child: Text('Aucun filtre')),
              DropdownMenuItem(value: 'Conférence', child: Text('Conférence')),
              DropdownMenuItem(value: 'Atelier', child: Text('Atelier')),
              DropdownMenuItem(value: 'Meetup', child: Text('Meetup')),
              DropdownMenuItem(value: 'Table ronde', child: Text('Table ronde')),
            ],
            onChanged: (value) {
              _persist(() => store.setDefaultCategoryFilter(value ?? ''));
            },
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<prefs.DisplayDensity>(
            initialValue: store.displayDensity,
            decoration: const InputDecoration(labelText: 'Densité d\'affichage'),
            items: const [
              DropdownMenuItem(
                value: prefs.DisplayDensity.comfortable,
                child: Text('Confortable'),
              ),
              DropdownMenuItem(
                value: prefs.DisplayDensity.compact,
                child: Text('Compact'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              _persist(() => store.setDisplayDensity(value));
            },
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<String>(
            initialValue: store.lastScreen,
            decoration: const InputDecoration(labelText: 'Dernier écran'),
            items: const [
              DropdownMenuItem(value: 'home', child: Text('Accueil')),
              DropdownMenuItem(value: 'drafts', child: Text('Brouillons')),
              DropdownMenuItem(value: 'settings', child: Text('Réglages')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              _persist(() => store.setLastScreen(value));
            },
          ),
        ],
      ),
    );
  }
}
