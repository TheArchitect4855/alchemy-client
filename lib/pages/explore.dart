import 'package:alchemy/components/profilestack.dart';
import 'package:alchemy/data/profile.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  final Future<List<Profile>> profilesFuture;
  final void Function(Profile profile, bool isLiked) onPopProfile;

  const ExplorePage({required this.profilesFuture, required this.onPopProfile, super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: profilesFuture,
    builder: (context, snapshot) {
      final theme = Theme.of(context);
      if (snapshot.hasData) {
            return ProfileStack(profiles: snapshot.data!, onPopProfile: onPopProfile);
      } else if (snapshot.hasError) {
        return Center(child: Column(children: [
          const Text('Error getting potential matches:', textAlign: TextAlign.center),
          Text(snapshot.error?.toString() ?? 'No further information', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium!.apply(color: theme.colorScheme.error)),
        ]));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
        },
      );
}
