import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/event_repository.dart';
import '../models/event_draft.dart';
import '../state/event_list_state.dart';
import '../theme/spacing.dart';

class EventSummaryScreen extends StatelessWidget {
  const EventSummaryScreen({super.key, required this.draft});

  final EventDraft draft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Récapitulatif')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          _SummaryRow(label: 'Titre', value: draft.title),
          _SummaryRow(label: 'Description', value: draft.description),
          _SummaryRow(label: 'Catégorie', value: draft.category),
          _SummaryRow(label: 'Capacité', value: '${draft.capacity}'),
          _SummaryRow(
            label: 'En ligne',
            value: draft.isOnline ? 'Oui' : 'Non',
          ),
          _SummaryRow(
            label: 'Adresse',
            value: draft.address ?? '—',
          ),
          _SummaryRow(
            label: 'Date de début',
            value: _formatDate(draft.startDate),
          ),
          _SummaryRow(
            label: 'Date de fin',
            value: _formatDate(draft.endDate),
          ),
          _SummaryRow(
            label: 'Heure de début',
            value: draft.startTime.format(context),
          ),
          _SummaryRow(
            label: 'Tarif',
            value: draft.isFree ? 'Gratuit' : '${draft.price.toStringAsFixed(2)} €',
          ),
          const SizedBox(height: Spacing.xl),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Modifier'),
          ),
          const SizedBox(height: Spacing.sm),
          FilledButton(
            onPressed: () => _confirm(context),
            child: const Text('Confirmer la création'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  void _confirm(BuildContext context) {
    context.read<EventRepository>().addFromDraft(draft);
    context.read<EventListNotifier>().load();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '« ${draft.title} » créé — début ${draft.formattedStartDate}',
        ),
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: Spacing.xs),
          Text(value),
        ],
      ),
    );
  }
}
