import 'package:flutter/material.dart';

class NumberBadge extends StatelessWidget {
  final int number;
  final Widget? child;

  const NumberBadge({required this.number, this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color(0xffcc0000),
        shape: BoxShape.circle,
      ),
      child: Text(number >= 9 ? '9+' : number.toString(), style: theme.textTheme.labelSmall!.apply(color: Colors.white)),
    );

    if (child == null) {
      return badge;
    } else {
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          child!,
          Positioned(
            top: -8,
            right: -8,
            child: badge,
          ),
        ],
      );
    }
  }
}
