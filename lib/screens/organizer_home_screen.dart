import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/organizer_event.dart';
import '../routes/app_routes.dart';
import '../theme/spacing.dart';
import '../utils/auth_error_translator.dart';

class OrganizerHomeScreen extends StatefulWidget {
  const OrganizerHomeScreen({super.key, required this.user});

  final User user;

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen> {
  String? _actionError;

  CollectionReference<Map<String, dynamic>> get _events =>
      FirebaseFirestore.instance.collection('events');

  Stream<QuerySnapshot<Map<String, dynamic>>> _myEventsStream() {
    return _events
        .where('ownerId', isEqualTo: widget.user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _resendVerification() async {
    try {
      await widget.user.sendEmailVerification();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Courriel de vérification envoyé.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translateAuthError(error))),
      );
    }
  }

  Future<void> _addEvent() async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvel événement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                autofocus: true,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Lieu (optionnel)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    final title = titleController.text.trim();
    final locationText = locationController.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.dispose();
      locationController.dispose();
    });

    if (confirmed != true || !mounted) {
      return;
    }

    if (title.isEmpty) {
      setState(() => _actionError = 'Le titre est obligatoire.');
      return;
    }

    setState(() => _actionError = null);

    try {
      final draft = OrganizerEvent(
        id: '',
        title: title,
        ownerId: widget.user.uid,
        createdAt: null,
        location: locationText.isEmpty ? null : locationText,
      );
      await _events.add(draft.toFirestoreCreate(widget.user.uid));
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _actionError = _firestoreMessage(error));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _actionError = 'Impossible d\'enregistrer l\'événement.',
      );
    }
  }

  Future<void> _deleteEvent(String docId) async {
    setState(() => _actionError = null);
    try {
      await _events.doc(docId).delete();
    } on FirebaseException catch (error) {
      setState(() => _actionError = _firestoreMessage(error));
    }
  }

  String _firestoreMessage(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Accès refusé : vous ne pouvez modifier que vos propres événements.';
    }
    if (error.code == 'failed-precondition') {
      return 'Index Firestore manquant pour cette requête. '
          'Console Firebase → Firestore → Index → créer un index composite '
          'sur la collection « events » : ownerId (croissant), '
          'createdAt (décroissant). Attendre quelques minutes puis réessayer.';
    }
    if (error.code == 'unavailable') {
      return 'Firestore est indisponible (réseau ou service). '
          'Vérifiez la connexion et réessayez.';
    }
    return 'Une erreur Firestore est survenue. Réessayez plus tard.';
  }

  @override
  Widget build(BuildContext context) {
        return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: widget.user,
      builder: (context, userSnapshot) {
        final user = userSnapshot.data ?? widget.user;
        final displayLabel = user.displayName?.trim().isNotEmpty == true
            ? user.displayName!
            : (user.email ?? user.uid);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Espace organisateur'),
            actions: [
              IconButton(
                tooltip: 'Application consommateur',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.consumerApp);
                },
                icon: const Icon(Icons.storefront_outlined),
              ),
              IconButton(
                tooltip: 'Profil',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
                icon: const Icon(Icons.person_outline),
              ),
              IconButton(
                tooltip: 'Déconnexion',
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addEvent,
            child: const Icon(Icons.add),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(
                  'Connecté : $displayLabel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (!user.emailVerified)
                MaterialBanner(
                  content: const Text(
                    'Votre adresse courriel n\'est pas encore vérifiée.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: _resendVerification,
                      child: const Text('Renvoyer'),
                    ),
                  ],
                ),
              if (_actionError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Text(
                    _actionError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _myEventsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final error = snapshot.error;
                      if (error is FirebaseException) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: Text(
                              _firestoreMessage(error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const Center(
                        child: Text('Impossible de charger vos événements.'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    final fromCache = snapshot.data?.metadata.isFromCache ?? false;

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (fromCache)
                              const Icon(Icons.cloud_off_outlined),
                            const Text('Aucun événement pour le moment.'),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (fromCache)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.lg,
                              vertical: Spacing.sm,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_off_outlined,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(width: Spacing.sm),
                                Text(
                                  'Données du cache local (en attente du serveur)',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(Spacing.lg),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: Spacing.sm),
                            itemBuilder: (context, index) {
                              final event = OrganizerEvent.fromFirestore(
                                docs[index],
                              );
                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Spacing.radiusMd,
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                ),
                                title: Text(event.title),
                                subtitle: Text(
                                  [
                                    if (event.location != null)
                                      event.location!,
                                    if (event.createdAt != null)
                                      'Créé le ${event.createdAt}',
                                  ].join(' · '),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteEvent(event.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
