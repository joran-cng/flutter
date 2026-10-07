import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/spacing.dart';
import '../utils/auth_error_translator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDisplayName() async {
    final name = _nameController.text.trim();
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await widget.user.updateDisplayName(name.isEmpty ? null : name);
      await widget.user.reload();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour.')),
      );
    } catch (error) {
      setState(() => _errorMessage = translateAuthError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: widget.user,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.user;
        final shownName = user.displayName?.trim().isNotEmpty == true
            ? user.displayName!
            : 'Non renseigné';

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Text('Courriel : ${user.email ?? '—'}'),
              const SizedBox(height: Spacing.sm),
              Text('Nom affiché : $shownName'),
              const SizedBox(height: Spacing.lg),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'affichage',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: Spacing.md),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _loading ? null : _saveDisplayName,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }
}
