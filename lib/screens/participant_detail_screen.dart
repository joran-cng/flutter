import 'package:flutter/material.dart';

import '../api/exceptions.dart';
import '../api/users_api.dart';
import '../models/participant.dart';
import '../theme/spacing.dart';

class ParticipantDetailScreen extends StatefulWidget {
  const ParticipantDetailScreen({super.key, required this.participantId});

  final int participantId;

  @override
  State<ParticipantDetailScreen> createState() => _ParticipantDetailScreenState();
}

class _ParticipantDetailScreenState extends State<ParticipantDetailScreen> {
  late final UsersApi _api;
  late final Future<Participant> _detailFuture;

  @override
  void initState() {
    super.initState();
    _api = UsersApi();
    _detailFuture = _api.fetchUserById(widget.participantId);
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche participant')),
      body: FutureBuilder<Participant>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(
                  _messageFor(snapshot.error!),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final participant = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: participant.imageUrl.isNotEmpty
                      ? NetworkImage(participant.imageUrl)
                      : null,
                  child: participant.imageUrl.isEmpty
                      ? Text(
                          participant.firstName.isNotEmpty
                              ? participant.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                participant.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              _DetailRow(label: 'E-mail', value: participant.email),
              _DetailRow(label: 'Entreprise', value: participant.companyName),
              if (participant.phone != null)
                _DetailRow(label: 'Téléphone', value: participant.phone!),
              if (participant.addressLine != null)
                _DetailRow(label: 'Adresse', value: participant.addressLine!),
            ],
          );
        },
      ),
    );
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Le service est momentanément indisponible, veuillez réessayer.';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Spacing.xs),
          Text(value),
        ],
      ),
    );
  }
}
