import 'package:alchemy/components/bottomcard.dart';
import 'package:flutter/material.dart';

class RedlistedPage extends StatelessWidget {
  const RedlistedPage({super.key});

  @override
  Widget build(BuildContext context) => const BottomCard(
    title: 'No Entry',
    children: [
      Text('You must be at least 18 years old to use Alchemy.'),
    ],
  );
}
