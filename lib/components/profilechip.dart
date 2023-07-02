import 'package:flutter/material.dart';

class ProfileChip extends StatelessWidget {
  final String text;
  final Color baseColor;

  const ProfileChip(this.text, {required this.baseColor, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: baseColor.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(8),
        color: _invertColor(baseColor).withOpacity(0.25),
      ),
      margin: const EdgeInsets.all(4),
      child: Text(text, style: theme.textTheme.labelSmall!.apply(color: baseColor)),
    );
  }

  Color _invertColor(Color color) {
    return Color.fromARGB(color.alpha, 255 - color.red, 255 - color.green, 255 - color.blue);
  }
}
