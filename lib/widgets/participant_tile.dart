import 'package:flutter/material.dart';

import '../models/participant.dart';
import '../theme/spacing.dart';

class ParticipantTile extends StatelessWidget {
  const ParticipantTile({
    super.key,
    required this.participant,
    required this.onTap,
  });

  final Participant participant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: participant.imageUrl.isNotEmpty
            ? NetworkImage(participant.imageUrl)
            : null,
        child: participant.imageUrl.isEmpty
            ? Text(
                participant.firstName.isNotEmpty
                    ? participant.firstName[0].toUpperCase()
                    : '?',
              )
            : null,
      ),
      title: Text(participant.fullName),
      subtitle: Text(
        '${participant.email}\n${participant.companyName}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
    );
  }
}
