import 'package:alchemy/components/bottomcard.dart';
import 'package:flutter/material.dart';

class MultiPageBottomCard extends StatelessWidget {
  final CrossAxisAlignment alignment;
  final String title;
  final List<Widget> children;
  final Widget? next;

  const MultiPageBottomCard({required this.title, required this.next, required this.children, this.alignment = CrossAxisAlignment.center, super.key});

  @override
  Widget build(BuildContext context) => BottomCard(
    crossAxisAlignment: alignment,
    title: title,
    children: [
      ...children,
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK'),
          ),
          FilledButton(
            onPressed: next == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => next!)),
            child: const Text('NEXT'),
          ),
        ],
      ),
    ],
  );
}
