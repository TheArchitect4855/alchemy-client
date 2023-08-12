import 'package:flutter/material.dart';

class FloatingText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final TextAlign alignment;

  const FloatingText(this.text, this.baseStyle, this.alignment, {super.key});

  @override
  Widget build(BuildContext context) {
    final shadowColor = Color(~baseStyle.color!.value | 0xff000000);
    return Text(
      text,
      style: baseStyle.apply(shadows: [Shadow(blurRadius: 8, color: shadowColor)]),
      textAlign: alignment,
    );
  }
}
