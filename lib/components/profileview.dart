import 'package:alchemy/components/photo_dots.dart';
import 'package:alchemy/components/profile_interact_buttons.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/data/profile_interaction.dart';
import 'package:flutter/material.dart';

const maxDisplayInterests = 5;

class ProfileView extends StatelessWidget {
  final Profile profile;
  final Set<ProfileInteraction> interactions;
  final int currentPhoto;
  final Key? infoButtonKey;
  final Key? likeButtonKey;
  final void Function(Set<ProfileInteraction>)? onInteract;
  final void Function()? onPressDetails;
  final void Function(int value)? onPhotoChanged;

  const ProfileView(this.profile, {
    required this.interactions,
    required this.currentPhoto,
    required this.onInteract,
    required this.onPressDetails,
    required this.onPhotoChanged,
      this.infoButtonKey,
      this.likeButtonKey,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white);
    final borderRadius = BorderRadius.circular(8);
    return DefaultTextStyle(
      style: textTheme.bodySmall!,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.white,
        ),
        margin: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: const [ BoxShadow(color: Colors.black54, blurRadius: 4) ],
            image: DecorationImage(
              image: NetworkImage(profile.photoUrls[currentPhoto]),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [ Colors.black87, Colors.transparent ],
              ),
            ),
            child: LayoutBuilder(builder: (context, constraints) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: GestureDetector(onTap: () => _setPhoto(currentPhoto - 1))),
                    Expanded(child: GestureDetector(onTap: () => _setPhoto(currentPhoto + 1))),
                  ],
                )),
                Row(children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            // The subtracted value is largely arbitrary. It'll need to be changed if the layout changes
                            // (I wish I knew of a better way to do this...)
                            constraints: BoxConstraints.loose(Size(constraints.maxWidth - 232, constraints.maxHeight)),
                            child: Text('${profile.name},', overflow: TextOverflow.ellipsis, style: textTheme.headlineMedium),
                          ),
                          Text(' ${profile.age}', style: textTheme.headlineMedium),
                        ],
                      ),
                      Text(profile.city),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.info_outline, color: Colors.white, size: 16), onPressed: onPressDetails),
                  const Spacer(),
                  ProfileInteractButtons(
                    profile: profile,
                    interactions: interactions,
                    onInteract: onInteract,
                  ),
                ]),
                Wrap(children: profile.buildChips(Colors.white, max: 8)),
                PhotoDots(count: profile.photoUrls.length, index: currentPhoto),
              ],
            )),
          ),
        ),
      ),
    );
  }

  void _setPhoto(int index) {
    if (onPhotoChanged == null) return;
    if (index >= profile.photoUrls.length) index = profile.photoUrls.length - 1;
    if (index < 0) index = 0;
    onPhotoChanged!(index);
  }
}
