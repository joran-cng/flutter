import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/event_repository.dart';
import '../models/registration.dart';
import '../state/registration_cart.dart';
import '../theme/spacing.dart';

class CartSummaryScreen extends StatelessWidget {
  const CartSummaryScreen({super.key});

  String _sessionLabel(EventRepository repository, Registration item) {
    final event = repository.findById(item.eventId);
    if (event == null) {
      return item.sessionId;
    }
    for (final session in event.sessions) {
      if (session.id == item.sessionId) {
        return session.label;
      }
    }
    return item.sessionId;
  }

  void _showResult(BuildContext context, CartOperationResult result) {
    if (result == CartOperationResult.success ||
        result == CartOperationResult.updated) {
      return;
    }
    final message = switch (result) {
      CartOperationResult.eventFull => 'Capacité dépassée.',
      CartOperationResult.quotaExceeded => 'Plafond utilisateur dépassé.',
      CartOperationResult.notFound => 'Inscription introuvable.',
      CartOperationResult.invalidQuantity => 'Quantité invalide.',
      _ => '',
    };
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<EventRepository>();
    final cart = context.watch<RegistrationCart>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon panier'),
        automaticallyImplyLeading: false,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Text(
                'Aucune inscription dans le panier.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                Text(
                  '${cart.distinctEventCount} événement(s) — '
                  '${cart.totalPlaces} place(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: Spacing.lg),
                for (final item in cart.items)
                  _CartItemTile(
                    title: repository.findById(item.eventId)?.title ??
                        item.eventId,
                    session: _sessionLabel(repository, item),
                    quantity: item.quantity,
                    onIncrement: () {
                      _showResult(
                        context,
                        context.read<RegistrationCart>().updateQuantity(
                              item.eventId,
                              item.quantity + 1,
                            ),
                      );
                    },
                    onDecrement: () {
                      _showResult(
                        context,
                        context.read<RegistrationCart>().updateQuantity(
                              item.eventId,
                              item.quantity - 1,
                            ),
                      );
                    },
                    onRemove: () {
                      context
                          .read<RegistrationCart>()
                          .removeRegistration(item.eventId);
                    },
                  ),
              ],
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.title,
    required this.session,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final String title;
  final String session;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: Spacing.xs),
            Text(session),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove)),
                Text('$quantity'),
                IconButton(onPressed: onIncrement, icon: const Icon(Icons.add)),
                const Spacer(),
                TextButton(onPressed: onRemove, child: const Text('Retirer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
