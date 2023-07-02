import 'package:alchemy/components/small_card.dart';
import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  final String photoUrl;
  final void Function() onRemove;

  const ProfilePhoto({required this.photoUrl, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = HSVColor.fromColor(theme.colorScheme.background).withValue(0.9).toColor();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SmallCard(child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
        )),
        Positioned(
          top: -12,
          right: -12,
          width: 24,
          height: 24,
          child: FilledButton(
            onPressed: onRemove,
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(color),
              elevation: const MaterialStatePropertyAll(2),
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
            ),
            child: const Icon(Icons.remove, size: 16),
          ),
        ),
      ],
    );
  }
}
