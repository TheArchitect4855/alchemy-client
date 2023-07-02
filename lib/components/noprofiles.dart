import 'package:flutter/material.dart';

class NoProfiles extends StatelessWidget {
  final String imageUrl;

  const NoProfiles({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final theme = Theme.of(context);
    final imageSize = constraints.maxWidth * 0.4;
    return FractionallySizedBox(
      widthFactor: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [ BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 8) ],
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(imageSize / 2),
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(width: imageSize, height: imageSize);
                },
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('No more profiles ~ \u{1f997}', style: theme.textTheme.bodyLarge),
          Text('There\'s no new people to see.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  });
}
