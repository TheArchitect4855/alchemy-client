import 'package:alchemy/components/bottomcard.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/services/updates.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key});

  @override
  Widget build(BuildContext context) => BottomCard(
    title: 'Update Required',
    children: [
      const Text('An update is required.'),
      FilledButton(
        onPressed: () async {
          final link = await UpdatesService.instance.getDownloadLink(RequestsService.instance);
          launchUrl(Uri.parse(link!), mode: LaunchMode.externalApplication);
        },
        child: const Text('Update Now'),
      ),
    ],
  );
}
