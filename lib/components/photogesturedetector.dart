import 'package:flutter/material.dart';

class PhotoGestureDetector extends StatelessWidget {
  final void Function() onTapLeft;
  final void Function() onTapRight;

  const PhotoGestureDetector({required this.onTapLeft, required this.onTapRight, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: GestureDetector(onTap: () => onTapLeft())),
        Expanded(child: GestureDetector(onTap: () => onTapRight())),
      ],
    );
  }
}
