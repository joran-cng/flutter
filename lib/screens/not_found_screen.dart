import 'package:flutter/material.dart';

import '../routes/navigation_helpers.dart';
import '../theme/spacing.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.error_outline, size: 64, color: scheme.error),
            const SizedBox(height: Spacing.lg),
            const Text(
              '404 — Route inconnue',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              routeName == null
                  ? 'Cette adresse de navigation n\'existe pas dans l\'application.'
                  : 'La route « $routeName » n\'est pas enregistrée.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => navigateToHomeRoot(context),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
