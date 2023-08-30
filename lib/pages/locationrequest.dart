import 'package:alchemy/components/bigbutton.dart';
import 'package:alchemy/components/bottomcard.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/init.dart';
import 'package:alchemy/services/location.dart';
import 'package:flutter/material.dart';

class LocationRequestPage extends StatelessWidget {
  const LocationRequestPage({super.key});

  @override
  Widget build(BuildContext context) => BottomCard(
    title: 'Location Access Required',
    children: [
      const Text('Alchemy needs location access to find potential matches near you.'),
      const SizedBox(height: 16),
      BigButton(text: 'Grant Access', onPressed: () => _requestPermission(context)),
    ],
  );

  void _requestPermission(BuildContext context) async {
    try {
      await LocationService.instance.requestPermission();
      if (!context.mounted) {
        Logger.error(runtimeType, 'Context was unmounted!');
        return;
      }

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const InitPage()), (route) => false);
    } on LocationServiceException {
      Logger.info(runtimeType, 'Permission was not granted');
    }
  }
}
