import 'package:flutter/material.dart';

import '../models/event.dart';
import '../theme/spacing.dart';
import '../utils/build_counter.dart';
import 'event_tile.dart';

class EventSection extends StatelessWidget {
  const EventSection({
    super.key,
    required this.title,
    required this.events,
    required this.compact,
    required this.onEventTap,
  });

  final String title;
  final List<Event> events;
  final bool compact;
  final ValueChanged<Event> onEventTap;

  @override
  Widget build(BuildContext context) {
    BuildCounter.eventSection++;
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        for (final event in events)
          EventTile(
            event: event,
            compact: compact,
            onOpen: () => onEventTap(event),
          ),
      ],
    );
  }
}
