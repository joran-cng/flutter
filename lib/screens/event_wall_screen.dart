import 'package:flutter/material.dart';

import '../data/sample_events.dart';
import '../models/event.dart';
import '../routes/app_routes.dart';
import '../theme/spacing.dart';
import '../widgets/category_pill.dart';
import '../widgets/event_card.dart';
import '../widgets/hero_header.dart';
import '../widgets/stat_indicator.dart';

class EventWallScreen extends StatefulWidget {
  const EventWallScreen({super.key});

  @override
  State<EventWallScreen> createState() => _EventWallScreenState();
}

class _EventWallScreenState extends State<EventWallScreen> {
  bool _isCompact = false;

  @override
  Widget build(BuildContext context) {
    final events = sampleEvents;
    final categories = events.map((e) => e.category).toSet();
    final totalRegistered = events.fold<int>(0, (sum, e) => sum + e.registered);
    final density = _isCompact
        ? EventCardDensity.compact
        : EventCardDensity.comfortable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planner'),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Compact', style: TextStyle(fontSize: 13)),
              Switch(
                value: _isCompact,
                onChanged: (value) => setState(() => _isCompact = value),
              ),
            ],
          ),
          const SizedBox(width: Spacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeroHeader(
              backgroundImageUrl: 'https://picsum.photos/seed/hero-bg/900/400',
              avatarImageUrl: 'https://picsum.photos/seed/avatar-host/200/200',
              title: 'Cycle Event Planner',
              tagline: 'Les rendez-vous tech qui font grandir votre réseau',
            ),
            const SizedBox(height: Spacing.lg),
            _StatsBar(
              eventCount: events.length,
              categoryCount: categories.length,
              registeredCount: totalRegistered,
            ),
            const SizedBox(height: Spacing.lg),
            _FiltersRow(categories: categories.toList()),
            const SizedBox(height: Spacing.md),
            _SectionHeader(count: events.length),
            const SizedBox(height: Spacing.xs),
            for (final event in events)
              _TappableEventCard(event: event, density: density),
            const SizedBox(height: Spacing.lg),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.eventCount,
    required this.categoryCount,
    required this.registeredCount,
  });

  final int eventCount;
  final int categoryCount;
  final int registeredCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: StatIndicator(
                  value: '$eventCount',
                  label: 'événements',
                ),
              ),
              const VerticalDivider(width: Spacing.lg, thickness: Spacing.hairline),
              Expanded(
                child: StatIndicator(
                  value: '$categoryCount',
                  label: 'catégories',
                ),
              ),
              const VerticalDivider(width: Spacing.lg, thickness: Spacing.hairline),
              Expanded(
                child: StatIndicator(
                  value: '$registeredCount',
                  label: 'inscrits',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  const _FiltersRow({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          const CategoryPill(label: 'Tout', selected: true),
          for (final category in categories) CategoryPill(label: category),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Prochains événements',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Text(
            '$count au total',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableEventCard extends StatelessWidget {
  const _TappableEventCard({
    required this.event,
    required this.density,
  });

  final Event event;
  final EventCardDensity density;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.eventDetail,
            arguments: event.id,
          );
        },
        child: EventCard(event: event, density: density),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xl,
        horizontal: Spacing.lg,
      ),
      child: Center(
        child: Text(
          '© 2026 Event Planner — Tous droits réservés',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
