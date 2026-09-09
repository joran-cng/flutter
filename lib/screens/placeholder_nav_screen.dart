import 'package:flutter/material.dart';

class PlaceholderNavScreen extends StatelessWidget {
  const PlaceholderNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Écran factice')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Retour'),
        ),
      ),
    );
  }
}
