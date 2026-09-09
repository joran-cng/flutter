import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../screens/main_shell.dart';
import '../state/registration_cart.dart';
import '../theme/spacing.dart';
import '../utils/date_label.dart';
import '../widgets/capacity_gauge.dart';
import '../widgets/cart_badge.dart';
import '../widgets/category_pill.dart';
import '../widgets/icon_label.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late String _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.event.sessions.first.id;
  }

  void _addToCart() {
    final result = context.read<RegistrationCart>().addRegistration(
          eventId: widget.event.id,
          sessionId: _selectedSessionId,
          quantity: 1,
        );
    final message = switch (result) {
      CartOperationResult.success => 'Ajouté au panier.',
      CartOperationResult.updated => 'Inscription mise à jour.',
      CartOperationResult.eventFull => 'Événement complet.',
      CartOperationResult.quotaExceeded =>
        'Plafond de ${RegistrationCart.maxUserPlaces} places atteint.',
      CartOperationResult.notFound => 'Événement introuvable.',
      CartOperationResult.invalidQuantity => 'Quantité invalide.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final scheme = Theme.of(context).colorScheme;
    final locationLabel =
        event.isOnline ? event.venue : '${event.venue}, ${event.city}';
    final cartQuantity = context.select<RegistrationCart, int>(
      (cart) => cart.reservedPlacesForEvent(event.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          CartBadge(
            onTap: () => MainShell.goToCartTabFrom(context),
          ),
        ],
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
            CapacityGauge(
              registered: event.registered,
              capacity: event.capacity,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              '${event.registered} / ${event.capacity} inscrits — '
              '$cartQuantity place(s) dans votre panier',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: Spacing.xl),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                for (final session in event.sessions)
                  ChoiceChip(
                    label: Text('${session.label} (${session.schedule})'),
                    selected: _selectedSessionId == session.id,
                    onSelected: (_) {
                      setState(() => _selectedSessionId = session.id);
                    },
                  ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: event.isSoldOut ? null : _addToCart,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Ajouter au panier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
