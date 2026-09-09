import 'package:flutter/material.dart';

import '../theme/spacing.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.backgroundImageUrl,
    required this.avatarImageUrl,
    required this.title,
    required this.tagline,
    this.height = 220,
  });

  final String backgroundImageUrl;
  final String avatarImageUrl;
  final String title;
  final String tagline;
  final double height;

  static const double _avatarDiameter = 56;
  static const double _avatarOverflow = 18;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + _avatarOverflow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    backgroundImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.blueGrey.shade800);
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: Spacing.lg,
                    right: Spacing.lg,
                    bottom: Spacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: height - _avatarDiameter + _avatarOverflow,
            right: Spacing.lg,
            child: Container(
              width: _avatarDiameter,
              height: _avatarDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: Image.network(
                  avatarImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(
                      color: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
