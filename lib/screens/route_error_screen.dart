import 'package:flutter/material.dart';

import '../routes/navigation_helpers.dart';
import '../theme/spacing.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Erreur de navigation')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.warning_amber_rounded, size: 64, color: scheme.error),
            const SizedBox(height: Spacing.lg),
            const Text(
              'Impossible d\'ouvrir cet écran',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => popToTabRoot(context),
              child: const Text('Revenir en arrière'),
            ),
          ],
        ),
      ),
    );
  }
}
