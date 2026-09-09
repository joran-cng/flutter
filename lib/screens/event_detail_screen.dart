import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/participation_package.dart';
import '../routes/app_routes.dart';
import '../routes/route_generator.dart';
import '../theme/spacing.dart';
import '../utils/date_label.dart';
import '../widgets/capacity_gauge.dart';
import '../widgets/category_pill.dart';
import '../widgets/icon_label.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  Future<void> _openPackageSelection(BuildContext context) async {
    final ParticipationPackage? chosen =
        await Navigator.pushNamed<ParticipationPackage?>(
      context,
      AppRoutes.packageSelection,
      arguments: event.id,
    );

    if (!context.mounted || chosen == null) {
      return;
    }

    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.confirmation,
      arguments: ConfirmationRouteArgs(event: event, package: chosen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locationLabel = event.isOnline
        ? event.venue
        : '${event.venue}, ${event.city}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l\'événement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
            const SizedBox(height: Spacing.md),
            CategoryPill(label: event.category, selected: true),
            const SizedBox(height: Spacing.lg),
            IconLabel(
              icon: event.isOnline ? Icons.wifi_outlined : Icons.place_outlined,
              label: locationLabel,
              style: TextStyle(color: scheme.onSurfaceVariant),
              iconColor: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.sm),
            IconLabel(
              icon: Icons.schedule_outlined,
              label: formatEventDate(event.date),
              style: TextStyle(color: scheme.onSurfaceVariant),
              iconColor: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Places',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            CapacityGauge(
              registered: event.registered,
              capacity: event.capacity,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              '${event.registered} / ${event.capacity} inscrits',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openPackageSelection(context),
                icon: const Icon(Icons.local_activity_outlined),
                label: const Text('Choisir une formule'),
              ),
            ),
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
