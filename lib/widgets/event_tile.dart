import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../state/registration_cart.dart';
import '../theme/spacing.dart';
import '../utils/build_counter.dart';
import '../widgets/capacity_gauge.dart';
import '../widgets/icon_label.dart';

class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    required this.compact,
    required this.onOpen,
    this.useWideConsumer = false,
  });

  final Event event;
  final bool compact;
  final VoidCallback onOpen;
  final bool useWideConsumer;

  @override
  Widget build(BuildContext context) {
    BuildCounter.eventTile++;
    if (useWideConsumer) {
      return Consumer<RegistrationCart>(
        builder: (context, cart, child) {
          return _EventTileBody(
            event: event,
            compact: compact,
            onOpen: onOpen,
            isInCart: cart.isEventInCart(event.id),
            onQuickAdd: () => _quickAdd(context),
          );
        },
      );
    }

    return Selector<RegistrationCart, bool>(
      selector: (_, cart) => cart.isEventInCart(event.id),
      builder: (context, isInCart, child) {
        return _EventTileBody(
          event: event,
          compact: compact,
          onOpen: onOpen,
          isInCart: isInCart,
          onQuickAdd: () => _quickAdd(context),
        );
      },
    );
  }

  void _quickAdd(BuildContext context) {
    if (event.sessions.isEmpty) {
      return;
    }
    final result = context.read<RegistrationCart>().addRegistration(
          eventId: event.id,
          sessionId: event.sessions.first.id,
          quantity: 1,
        );
    _showResult(context, result);
  }

  void _showResult(BuildContext context, CartOperationResult result) {
    final message = switch (result) {
      CartOperationResult.success => 'Ajouté au panier.',
      CartOperationResult.updated => 'Inscription mise à jour.',
      CartOperationResult.eventFull => 'Événement complet.',
      CartOperationResult.quotaExceeded => 'Plafond de $RegistrationCart.maxUserPlaces places atteint.',
      CartOperationResult.notFound => 'Événement introuvable.',
      CartOperationResult.invalidQuantity => 'Quantité invalide.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EventTileBody extends StatelessWidget {
  const _EventTileBody({
    required this.event,
    required this.compact,
    required this.onOpen,
    required this.isInCart,
    required this.onQuickAdd,
  });

  final Event event;
  final bool compact;
  final VoidCallback onOpen;
  final bool isInCart;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final thumbnailSize = compact ? 56.0 : 72.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: isInCart
                ? scheme.primaryContainer.withValues(alpha: 0.35)
                : scheme.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Image.network(
                  event.imageUrl,
                  width: thumbnailSize,
                  height: thumbnailSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: thumbnailSize,
                    height: thumbnailSize,
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.event, color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    IconLabel(
                      icon: Icons.place_outlined,
                      label: event.isOnline
                          ? event.venue
                          : '${event.venue}, ${event.city}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      iconColor: scheme.onSurfaceVariant,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: Spacing.sm),
                      CapacityGauge(
                        registered: event.registered,
                        capacity: event.capacity,
                      ),
                    ],
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        if (isInCart)
                          Padding(
                            padding: const EdgeInsets.only(right: Spacing.sm),
                            child: Icon(
                              Icons.check_circle,
                              size: 16,
                              color: scheme.primary,
                            ),
                          ),
                        TextButton(
                          onPressed: event.isSoldOut ? null : onQuickAdd,
                          child: const Text('+1 place'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
