import 'package:flutter/material.dart';

class SmallCard extends StatelessWidget {
  final Widget? child;

  const SmallCard({this.child, super.key});

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: BoxConstraints.tight(const Size(96, 128)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
}
