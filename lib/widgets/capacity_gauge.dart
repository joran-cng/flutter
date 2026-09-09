import 'package:flutter/material.dart';

class CapacityGauge extends StatelessWidget {
  const CapacityGauge({
    super.key,
    required this.registered,
    required this.capacity,
    this.height = 6,
  });

  final int registered;
  final int capacity;
  final double height;

  double get _ratio {
    if (capacity <= 0) return 0;
    final raw = registered / capacity;
    return raw.clamp(0.0, 1.0);
  }

  Color _colorForRatio(ColorScheme scheme) {
    final ratio = _ratio;
    if (ratio >= 1.0) return scheme.error;
    if (ratio >= 0.75) return Colors.orange;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(height: height, color: scheme.surfaceContainerHighest),
          FractionallySizedBox(
            widthFactor: _ratio,
            child: Container(height: height, color: _colorForRatio(scheme)),
          ),
        ],
      ),
    );
  }
}
