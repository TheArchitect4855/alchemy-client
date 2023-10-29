import 'package:alchemy/components/photo_dots.dart';
import 'package:alchemy/components/profile_interact_buttons.dart';
import 'package:alchemy/components/profilechip.dart';
import 'package:alchemy/components/report_profile.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/data/profile_interaction.dart';
import 'package:alchemy/strings.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Profile profile;
  final int currentPhoto;
  final Set<ProfileInteraction>? interactions;
  final void Function(int photo) onPhotoChanged;
  final Key? backButtonKey;

  const ProfilePage(this.profile,
      {required this.currentPhoto, required this.interactions, required this.onPhotoChanged, this.backButtonKey, super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late int _currentPhoto;
  late Set<ProfileInteraction>? _interactions;

  @override
  void initState() {
    super.initState();
    _currentPhoto = widget.currentPhoto;
    _interactions = widget.interactions;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    final wrapContent = <Widget>[
      Text('${widget.profile.name}, ${widget.profile.age}', style: theme.textTheme.headlineLarge),
    ];

    if (_interactions != null) {
      wrapContent.add(ProfileInteractButtons(
        profile: widget.profile,
        interactions: _interactions!,
        onInteract: (v) => setState(() => _interactions = v),
      ));
    }

    final listContent = <Widget>[
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: wrapContent,
      ),
      Row(children: [
        Text(widget.profile.pronouns ?? '', style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        Text(widget.profile.city, style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_circle_down, size: 16, key: widget.backButtonKey),
        ),
      ]),
    ];

    if (widget.profile.bio.isNotEmpty) {
      listContent.addAll([
        const SizedBox(height: 16),
        Text(widget.profile.bio),
      ]);
    }

    if (widget.profile.relationshipInterests.isNotEmpty) {
      listContent.addAll([
        const SizedBox(height: 16),
        Text('Relationship Interests', style: theme.textTheme.labelMedium),
        Wrap(children: widget.profile.relationshipInterests.map((e) => ProfileChip(capitalizeWords(e), baseColor: Colors.black)).toList()),
      ]);
    }

    if (widget.profile.neurodiversities.isNotEmpty) {
      listContent.addAll([
        const SizedBox(height: 16),
        Text('Neurodiversities', style: theme.textTheme.labelMedium),
        Wrap(children: widget.profile.neurodiversities.map((e) => ProfileChip(capitalizeWords(e), baseColor: Colors.black)).toList()),
      ]);
    }

    if (widget.profile.interests.isNotEmpty) {
      listContent.addAll([
        const SizedBox(height: 16),
        Text('Interests', style: theme.textTheme.labelMedium),
        Wrap(children: widget.profile.interests.map((e) => ProfileChip(capitalizeWords(e), baseColor: Colors.black)).toList()),
      ]);
    }

    listContent.addAll([
      const SizedBox(height: 16),
      TextButton.icon(
        onPressed: () => showDialog(context: context, builder: (context) => ReportProfile(widget.profile)),
        style: theme.textButtonTheme.style?.copyWith(
          foregroundColor: const MaterialStatePropertyAll(Colors.black26),
        ),
        icon: const Icon(Icons.flag),
        label: const Text('Report Profile'),
      ),
    ]);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox.square(
            dimension: mediaQuery.size.width,
            child: Stack(
              alignment: Alignment.bottomCenter,
              fit: StackFit.expand,
              children: [
                Image.network(widget.profile.photoUrls[_currentPhoto], fit: BoxFit.cover),
                Positioned(
                  left: 0,
                  width: mediaQuery.size.width / 2,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(onTap: () => _setCurrentPhoto(_currentPhoto - 1)),
                ),
                Positioned(
                  right: 0,
                  width: mediaQuery.size.width / 2,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(onTap: () => _setCurrentPhoto(_currentPhoto + 1)),
                ),
                Positioned(
                  bottom: 16,
                  child: PhotoDots(count: widget.profile.photoUrls.length, index: _currentPhoto),
                ),
              ],
            ),
          ),
          SizedBox(
            width: mediaQuery.size.width,
            height: mediaQuery.size.height - mediaQuery.size.width,
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: listContent,
            ),
          ),
        ],
      ),
    );
  }

  void _setCurrentPhoto(int index) {
    if (index >= widget.profile.photoUrls.length) index = widget.profile.photoUrls.length - 1;
    if (index < 0) index = 0;
    widget.onPhotoChanged(index);
    setState(() {
      _currentPhoto = index;
    });
  }
}
