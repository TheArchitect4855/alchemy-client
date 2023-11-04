import 'package:flutter/material.dart';

class PhotoDots extends StatelessWidget {
  final int count;
  final int index;

  const PhotoDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[];
    for (var i = 0; i < count; i += 1) {
      final color = i == index ? Colors.white : Colors.white70;
      dots.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: color,
        ),
        width: 8,
        height: 8,
        margin: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }
}
