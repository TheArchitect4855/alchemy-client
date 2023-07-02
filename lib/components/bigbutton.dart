import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const BigButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: 0.5,
    child: FilledButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, textAlign: TextAlign.center),
      ),
    ),
  );
}
