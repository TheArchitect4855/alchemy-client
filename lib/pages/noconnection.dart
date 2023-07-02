import 'package:alchemy/components/bottomcard.dart';
import 'package:flutter/material.dart';

class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage({super.key});

  @override
  Widget build(BuildContext context) => const BottomCard(
    title: 'No Connection',
    children: [
      Text('Could not connect to server. Please try again later.'),
    ],
  );
}
