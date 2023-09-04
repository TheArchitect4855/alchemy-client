import 'package:alchemy/components/profilestack.dart';
import 'package:alchemy/data/profile.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  final List<Profile>? profiles;
  final void Function(Profile profile, bool isLiked) onPopProfile;

  const ExplorePage(
      {required this.profiles, required this.onPopProfile, super.key});

  @override
  Widget build(BuildContext context) {
    if (profiles == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ProfileStack(profiles: profiles!, onPopProfile: onPopProfile);
  }
}
