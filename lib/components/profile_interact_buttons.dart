import 'package:alchemy/data/profile.dart';
import 'package:alchemy/data/profile_interaction.dart';
import 'package:flutter/material.dart';

class ProfileInteractButtons extends StatelessWidget {
  final Profile profile;
  final Set<ProfileInteraction> interactions;
  final void Function(Set<ProfileInteraction>)? onInteract;

  const ProfileInteractButtons({super.key, required this.profile, required this.interactions, required this.onInteract});

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = ProfileInteraction.values
      .where((e) => profile.relationshipInterests.contains(e.relationshipInterest))
      .map((e) {
        final image = Image.asset(interactions.contains(e) ? e.getIconFile() : e.getSilhouetteFile(), width: 32);
        return IconButton(
          onPressed: onInteract == null ? null : () {
            if (interactions.contains(e)) {
              interactions.remove(e);
            } else {
              interactions.add(e);
            }

            onInteract!(interactions);
          },
          icon: image,
        );
      }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }
}
