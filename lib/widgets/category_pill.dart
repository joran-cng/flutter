import 'package:flutter/material.dart';

import '../theme/spacing.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({super.key, required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: Spacing.hairline,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
