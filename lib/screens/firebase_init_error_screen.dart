import 'package:flutter/material.dart';

import '../theme/spacing.dart';

class FirebaseInitErrorScreen extends StatelessWidget {
  const FirebaseInitErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.cloud_off,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Firebase n\'a pas pu démarrer',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Spacing.md),
              const Text(
                'Vérifiez la configuration FlutterFire (firebase_options.dart, '
                'google-services.json) et relancez l\'application.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
