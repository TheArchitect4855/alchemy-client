import 'dart:math';
import 'package:alchemy/components/photogesturedetector.dart';
import 'package:alchemy/components/profilechip.dart';
import 'package:alchemy/components/report_profile.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/strings.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Profile profile;
  final int currentPhoto;
  final bool isLiked;
  final void Function(int photo) onPhotoChanged;
  final Key? backButtonKey;
  final void Function(bool isLiked)? onLike;

  const ProfilePage(this.profile,
      {required this.currentPhoto, required this.isLiked, required this.onLike, required this.onPhotoChanged, this.backButtonKey, super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late int _currentPhoto;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _currentPhoto = widget.currentPhoto;
    _isLiked = widget.isLiked;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(builder: (context, constraints) {
      final theme = Theme.of(context);
      final imageSize = min(constraints.maxWidth, constraints.maxHeight * 0.6);
      final photoUrls = widget.profile.photoUrls;
      final currentPhotoUrl = photoUrls.isEmpty ? null : photoUrls[_currentPhoto];

      final profileElements = <Widget>[
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${widget.profile.name}, ', style: theme.textTheme.headlineLarge),
            Text(widget.profile.age.toString(), style: theme.textTheme.headlineLarge),
            const SizedBox(width: 16),
            Text(widget.profile.city, style: theme.textTheme.labelMedium),
            IconButton(
                  key: widget.backButtonKey,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_circle_down, size: 18, color: Colors.black45),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(widget.profile.bio, style: theme.textTheme.bodyMedium),
      ];

      if (widget.profile.pronouns != null) {
        profileElements.addAll([
          const SizedBox(height: 8),
          Text(widget.profile.pronouns!),
        ]);
      }

      profileElements.addAll([
        const SizedBox(height: 8),
        const Text('Relationship Interests'),
        Wrap(children: widget.profile.relationshipInterests.map((e) => ProfileChip(capitalizeWords(e), baseColor: Colors.black)).toList()),
      ]);

      if (widget.profile.neurodiversities.isNotEmpty) {
        profileElements.addAll([
          const SizedBox(height: 8),
          const Text('Neurodiversities'),
          Wrap(children: widget.profile.neurodiversities.map((e) => ProfileChip(e, baseColor: Colors.black)).toList()),
        ]);
      }

      if (widget.profile.interests.isNotEmpty) {
        profileElements.addAll([
          const SizedBox(height: 8),
          const Text('Interests'),
          Wrap(children: widget.profile.interests.map((e) => ProfileChip(e, baseColor: Colors.black)).toList()),
        ]);
      }

      final stackElements = <Widget>[
        currentPhotoUrl == null ? const ColoredBox(color: Colors.black) : Image(
          image: NetworkImage(currentPhotoUrl),
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: PhotoGestureDetector(
            onTapLeft: () => _setCurrentPhoto(_currentPhoto - 1),
            onTapRight: () => _setCurrentPhoto(_currentPhoto + 1),
          ),
        ),
      ];

      if (widget.onLike != null) {
        stackElements.add(Positioned(
          right: 8,
          bottom: 8,
          child: IconButton(
            onPressed: () => setState(() {
              _isLiked = !_isLiked;
              widget.onLike!(_isLiked);
            }),
            icon: Icon(Icons.favorite, size: 48, color: _isLiked ? Colors.red : Colors.white, shadows: const [ Shadow(blurRadius: 16) ]),
          ),
        ));
      }

      stackElements.add(Positioned(
        bottom: 8,
        width: constraints.maxWidth,
        child: _buildPhotoDots(theme),
      ));

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: imageSize,
            height: imageSize,
            child: Stack(
              fit: StackFit.expand,
              children: stackElements,
            ),
          ),
          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DefaultTextStyle.merge(
                style: theme.textTheme.labelLarge!.apply(color: Colors.black),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: profileElements,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => ReportProfile(widget.profile)),
                  icon: const Icon(Icons.flag),
                  label: const Text('Report Profile'),
                  style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.black26),
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
              ),
            ],
          )),
        ],
      );
    }),
  );

  Widget _buildPhotoDots(ThemeData theme) {
    final dots = <Widget>[];
    for (var i = 0; i < widget.profile.photoUrls.length; i += 1) {
      var color = theme.colorScheme.background;
      if (i != _currentPhoto) color = color.withOpacity(0.75);

      dots.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          boxShadow: const [ BoxShadow(blurRadius: 8) ],
          shape: BoxShape.circle,
        ),
        child: const SizedBox(width: 8, height: 8),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }

  void _setCurrentPhoto(int value) => setState(() {
    _currentPhoto = min(widget.profile.photoUrls.length - 1, max(0, value));
    widget.onPhotoChanged(_currentPhoto);
  });
}
