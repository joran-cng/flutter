import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../routes/app_routes.dart';
import '../screens/main_shell.dart';
import '../state/display_preferences.dart';
import '../state/event_list_state.dart';
import '../theme/spacing.dart';
import '../utils/build_counter.dart';
import '../widgets/cart_badge.dart';
import '../widgets/event_section.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final ValueNotifier<bool> _helpExpanded = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<EventListNotifier>().load();
    });
  }

  @override
  void dispose() {
    _helpExpanded.dispose();
    super.dispose();
  }

  List<Event> _applyPreferences(List<Event> events, DisplayPreferences prefs) {
    var filtered = events;
    if (prefs.categoryFilter != null) {
      filtered = filtered
          .where((event) => event.category == prefs.categoryFilter)
          .toList();
    }

    final sorted = List<Event>.from(filtered);
    sorted.sort((a, b) {
      return switch (prefs.sortCriterion) {
        EventSortCriterion.title => a.title.compareTo(b.title),
        EventSortCriterion.date => a.date.compareTo(b.date),
        EventSortCriterion.remainingPlaces =>
          b.remainingPlaces.compareTo(a.remainingPlaces),
      };
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final listState = context.watch<EventListNotifier>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planner'),
        automaticallyImplyLeading: false,
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            IconButton(
              icon: const Icon(Icons.dashboard_outlined),
              tooltip: 'Espace organisateur',
              onPressed: () => MainShell.returnToOrganizer(context),
            ),
          CartBadge(
            onTap: () => MainShell.goToCartTabFrom(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Réglages',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          IconButton(
            icon: const Icon(Icons.drafts_outlined),
            tooltip: 'Brouillons',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.draftList);
            },
          ),
          IconButton(
            icon: const Icon(Icons.contacts_outlined),
            tooltip: 'Annuaire',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.directory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            tooltip: 'Inscription',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.registration);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Créer un événement',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.eventCreation);
            },
          ),
        ],
      ),
      body: switch (listState) {
        EventListLoading() => const Center(child: CircularProgressIndicator()),
        EventListError(:final message) => _ErrorBody(
            message: message,
            onRetry: () => context.read<EventListNotifier>().load(),
            onSimulateError: () =>
                context.read<EventListNotifier>().load(simulateError: true),
          ),
        EventListLoaded(:final events) => _LoadedBody(
            events: events,
            helpExpanded: _helpExpanded,
            applyPreferences: _applyPreferences,
          ),
      },
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.events,
    required this.helpExpanded,
    required this.applyPreferences,
  });

  final List<Event> events;
  final ValueNotifier<bool> helpExpanded;
  final List<Event> Function(List<Event>, DisplayPreferences) applyPreferences;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<DisplayPreferences>();
    final visibleEvents = applyPreferences(events, prefs);
    final categories = events.map((event) => event.category).toSet().toList()
      ..sort();
    final compact = prefs.density == DisplayDensity.compact;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: helpExpanded,
            builder: (context, expanded, child) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Aide rapide'),
                    trailing: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () => helpExpanded.value = !helpExpanded.value,
                  ),
                  if (expanded)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                      child: Text(
                        'Parcourez les événements, ajoutez des places au panier '
                        'depuis la liste ou le détail. Le badge panier se met à jour '
                        'sur tous les écrans.',
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                FilterChip(
                  label: const Text('Tout'),
                  selected: prefs.categoryFilter == null,
                  onSelected: (_) =>
                      context.read<DisplayPreferences>().setCategoryFilter(null),
                ),
                for (final category in categories)
                  FilterChip(
                    label: Text(category),
                    selected: prefs.categoryFilter == category,
                    onSelected: (_) => context
                        .read<DisplayPreferences>()
                        .setCategoryFilter(category),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<EventSortCriterion>(
                    initialValue: prefs.sortCriterion,
                    decoration: const InputDecoration(labelText: 'Tri'),
                    items: const [
                      DropdownMenuItem(
                        value: EventSortCriterion.title,
                        child: Text('Titre'),
                      ),
                      DropdownMenuItem(
                        value: EventSortCriterion.date,
                        child: Text('Date'),
                      ),
                      DropdownMenuItem(
                        value: EventSortCriterion.remainingPlaces,
                        child: Text('Places restantes'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<DisplayPreferences>()
                            .setSortCriterion(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Compact'),
                    Switch(
                      value: compact,
                      onChanged: (value) {
                        context.read<DisplayPreferences>().setDensity(
                              value
                                  ? DisplayDensity.compact
                                  : DisplayDensity.comfortable,
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          EventSection(
            title: 'Événements (${visibleEvents.length})',
            events: visibleEvents,
            compact: compact,
            onEventTap: (event) {
              Navigator.pushNamed(
                context,
                AppRoutes.eventDetail,
                arguments: event.id,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(
              'Recompositions — tuile: ${BuildCounter.eventTile}, '
              'section: ${BuildCounter.eventSection}, '
              'badge: ${BuildCounter.cartBadge}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              BuildCounter.reset();
              context.read<DisplayPreferences>().setSortCriterion(
                    prefs.sortCriterion == EventSortCriterion.title
                        ? EventSortCriterion.date
                        : EventSortCriterion.title,
                  );
            },
            child: const Text('Réinitialiser compteurs / changer tri (test C.1)'),
          ),
          TextButton(
            onPressed: () =>
                context.read<EventListNotifier>().load(simulateError: true),
            child: const Text('Simuler une erreur de chargement'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.onSimulateError,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSimulateError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: Spacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: Spacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
            TextButton(
              onPressed: onSimulateError,
              child: const Text('Relancer en mode erreur'),
            ),
          ],
        ),
      ),
    );
  }
}
