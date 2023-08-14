import 'dart:math';
import 'package:alchemy/components/photogesturedetector.dart';
import 'package:alchemy/data/profile.dart';
import 'package:flutter/material.dart';

const maxDisplayInterests = 5;

class ProfileView extends StatelessWidget {
  final Profile profile;
  final bool isLiked;
  final int currentPhoto;
  final Key? infoButtonKey;
  final Key? likeButtonKey;
  final void Function()? onPressDetails;
  final void Function(bool value)? onLike;
  final void Function(int value)? onPhotoChanged;

  const ProfileView(this.profile, {
    required this.isLiked,
    required this.currentPhoto,
    required this.onPressDetails,
    required this.onLike,
    required this.onPhotoChanged,
      this.infoButtonKey,
      this.likeButtonKey,
    super.key
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final theme = Theme.of(context);
    final headlineWhite = theme.textTheme.headlineLarge!.apply(color: Colors.white);
    final chips = profile.buildChips(Colors.white, max: maxDisplayInterests);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        image: profile.photoUrls.isEmpty ? null : DecorationImage(
          image: NetworkImage(profile.photoUrls[currentPhoto]),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [ BoxShadow(blurRadius: 8) ],
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [ Colors.black, Colors.transparent ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: PhotoGestureDetector(
              onTapLeft: () => _setCurrentPhoto(currentPhoto - 1),
              onTapRight: () => _setCurrentPhoto(currentPhoto + 1),
            )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth - 145),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${profile.name}, ', style: headlineWhite, overflow: TextOverflow.ellipsis),
                      Text(profile.age.toString(), style: headlineWhite),
                      const SizedBox(width: 16),
                      Text(profile.city, style: theme.textTheme.labelMedium!.apply(color: Colors.white)),
                    ],
                  ),
                ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        onPressed: onPressDetails,
                        icon: Icon(Icons.info_outline, size: 18, color: Colors.white, key: infoButtonKey),
                      ),
                    )),
                    IconButton(
                      key: likeButtonKey,
                      onPressed: onLike == null ? null : () => onLike!(!isLiked),
                      icon: Icon(Icons.favorite, size: 48, color: isLiked ? Colors.red : Colors.white),
                    ),
              ],
            ),
            Wrap(
              children: chips,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPhotoDots(theme),
            ),
          ],
        ),
      ),
    );
  });

  List<Widget> _buildPhotoDots(ThemeData theme) {
    final res = <Widget>[];
    for (var i = 0; i < profile.photoUrls.length; i += 1) {
      var color = theme.colorScheme.background;
      if (i != currentPhoto) color = color.withOpacity(0.75);

      res.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          boxShadow: const [ BoxShadow(blurRadius: 8) ],
          shape: BoxShape.circle,
        ),
        child: const SizedBox(width: 8, height: 8),
      ));
    }

    return res;
  }

  void _setCurrentPhoto(int value) {
    if (onPhotoChanged == null) return;

    int newValue = min(profile.photoUrls.length - 1, max(0, value));
    onPhotoChanged!(newValue);
  }
}
