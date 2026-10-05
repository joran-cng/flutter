import 'package:flutter/material.dart';

import '../theme/spacing.dart';
import '../validation/validators.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _placesController = TextEditingController();
  final _emailController = TextEditingController();

  final _nameFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _placesFocus = FocusNode();
  final _emailFocus = FocusNode();

  bool _showAutoValidation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _placesController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _cityFocus.dispose();
    _placesFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _showAutoValidation = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscription enregistrée (simulation).')),
    );
    _formKey.currentState!.reset();
    setState(() => _showAutoValidation = false);
    _nameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Form(
        key: _formKey,
        autovalidateMode: _showAutoValidation
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nom complet'),
              validator: fullNameValidator,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_cityFocus),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _cityController,
              focusNode: _cityFocus,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Lieu de résidence'),
              validator: cityValidator,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_placesFocus),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _placesController,
              focusNode: _placesFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre de places demandées',
              ),
              validator: positiveIntValidator,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_emailFocus),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Courriel de contact',
              ),
              validator: emailValidator,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: Spacing.xl),
            FilledButton(
              onPressed: _submit,
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
