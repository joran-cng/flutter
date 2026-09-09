import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/participation_package.dart';
import '../routes/navigation_helpers.dart';
import '../theme/spacing.dart';
import '../utils/date_label.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    super.key,
    required this.event,
    required this.package,
  });

  final Event event;
  final ParticipationPackage package;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: scheme.primary,
            ),
            const SizedBox(height: Spacing.lg),
            const Text(
              'Réservation enregistrée',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.xl),
            _SummaryRow(label: 'Événement', value: event.title),
            _SummaryRow(label: 'Date', value: formatEventDate(event.date)),
            _SummaryRow(label: 'Formule', value: package.name),
            _SummaryRow(
              label: 'Tarif',
              value: '${package.price.toStringAsFixed(0)} €',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => popToTabRoot(context),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
