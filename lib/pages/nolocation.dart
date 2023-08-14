import 'package:alchemy/components/bottomcard.dart';
import 'package:flutter/material.dart';

class NoLocationPage extends StatelessWidget {
  const NoLocationPage({super.key});

  @override
  Widget build(BuildContext context) => const BottomCard(
        title: 'No Location',
        children: [
          Text('Could not get your location. Please try again later.'),
        ],
      );
}
