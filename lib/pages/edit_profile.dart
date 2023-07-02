import 'package:alchemy/components/chipselector.dart';
import 'package:alchemy/components/confirmationdialog.dart';
import 'package:alchemy/components/photo_upload_button.dart';
import 'package:alchemy/components/profile_photo.dart';
import 'package:alchemy/components/small_card.dart';
import 'package:alchemy/components/wide_text_field.dart';
import 'package:alchemy/gender_kind.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/photos.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alchemy/snackbar_util.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _genderInputController;
  late String _name;
  late String _bio;
  late GenderKind _genderKind;
  late List<String> _photoUrls;
  late Set<String> _relationshipInterests;
  late Set<String> _neurodiversities;
  late Set<String> _interests;
  late String? _pronouns;
  late Future<String> _neurodiversitiesFuture;
  late Future<String> _interestsFuture;
  bool _isUploadingPhoto = false;
  String? _genderIdentity;
  List<String>? _allNeurodiversities;
  List<String>? _allInterests;

  @override
  void initState() {
    super.initState();
    _genderInputController = TextEditingController();

    final profile = AuthService.instance.profile!;
    _name = profile.name;
    _bio = profile.bio;
    _photoUrls = profile.photoUrls;
    _relationshipInterests = profile.relationshipInterests.map((e) => capitalizeWords(e.trim())).toSet();
    _neurodiversities = profile.neurodiversities.map((e) => e.trim()).toSet();
    _interests = profile.interests.map((e) => e.trim()).toSet();
    _pronouns = profile.pronouns;

    _genderKind = profile.genderKind;
    if (_genderKind == GenderKind.nonbinary) {
      _genderIdentity = profile.gender;
      if (profile.gender != 'nonbinary') _genderInputController.text = profile.gender;
    }

    _neurodiversitiesFuture = rootBundle.loadString('assets/neurodiversities.txt');
    _interestsFuture = rootBundle.loadString('assets/interests.txt');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photos = _photoUrls.map((e) => ProfilePhoto(
      photoUrl: e,
      onRemove: () => _removePhoto(e),
    )).toList();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...photos,
                  _isUploadingPhoto ? const SmallCard(child: Center(child: CircularProgressIndicator())) : PhotoUploadButton(onUploadStart: _uploadPhoto),
                ],
              ),
            ),
            WideTextField(
              defaultValue: _name,
              labelText: 'Name',
              maxLength: 128,
              onChanged: (v) => setState(() {
                _name = v;
              }),
            ),
            WideTextField(
              defaultValue: _pronouns ?? '',
              labelText: 'Pronouns',
              maxLength: 32,
              onChanged: (v) => setState(() {
                _pronouns = v;
              }),
            ),
            WideTextField(
              defaultValue: _bio,
              labelText: 'Bio',
              maxLength: 1024,
              maxLines: null,
              onChanged: (v) => setState(() {
                _bio = v;
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildConditionals(theme),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FilledButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ),
      ]
    );
  }

  List<Widget> _buildConditionals(ThemeData theme) {
    final res = <Widget>[
      Text('Gender', style: theme.textTheme.labelMedium),
      const SizedBox(height: 8),
      SegmentedButton(
        segments: const [
          ButtonSegment(value: GenderKind.man, label: Text('Man')),
          ButtonSegment(value: GenderKind.nonbinary, label: Text('Non-Binary')),
          ButtonSegment(value: GenderKind.woman, label: Text('Woman')),
        ],
        selected: { _genderKind },
        onSelectionChanged: (v) => setState(() {
          _genderKind = v.first;
        }),
      ),
    ];

    if (_genderKind == GenderKind.nonbinary) {
      res.addAll([
        const SizedBox(height: 8),
        TextField(
          controller: _genderInputController,
          decoration: InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (v) => setState(() {
            _genderIdentity = v;
          }),
        ),
      ]);
    }

    res.addAll([
      const SizedBox(height: 32),
      ChipSelector(
        label: 'Relationship Interests',
        options: const [
          'Flings',
          'Friends',
          'Romance',
        ],
        selected: _relationshipInterests,
        onChanged: (_, selected) => setState(() {
          _relationshipInterests = selected;
        }),
      ),
      const SizedBox(height: 16),
      FutureBuilder(
        future: _neurodiversitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_allNeurodiversities == null) {
              final allSet = snapshot.data!.split('\n').map((e) => e.trim()).toSet();
              allSet.addAll(_neurodiversities);
              _allNeurodiversities = allSet.toList();
            }

            return ChipSelector(
              label: 'Neurodiversities',
              options: _allNeurodiversities!,
              selected: _neurodiversities,
              onChanged: (values, selected) => setState(() {
                _allNeurodiversities = values;
                _neurodiversities = selected;
              }),
              allowOther: true,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      const SizedBox(height: 16),
      FutureBuilder(
        future: _interestsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allInterests ??= snapshot.data!.split('\n').map((e) => e.trim()).toList();
            return ChipSelector(
              label: 'Interests',
              options: _allInterests!,
              selected: _interests,
              onChanged: (_, selected) => setState(() {
                _interests = selected;
              }),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      const SizedBox(height: 32),
    ]);

    return res;
  }

  void _removePhoto(String url) async {
    if (_photoUrls.length <= 1) {
      textSnackbar(context, 'You must have at least one photo');
      return;
    }

    final confirm = await const ConfirmationDialog(
      action: 'Remove Photo',
      detail: 'Are you sure you want to remove this photo?',
    ).show(context);

    if (confirm) {
      setState(() {
        _photoUrls.remove(url);
      });
      
      await PhotosService.instance.removePhoto(url, RequestsService.instance);
    }
  }

  void _uploadPhoto(Future<String> urlFuture) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final url = await urlFuture;
      setState(() {
        _photoUrls.add(url);
      });
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Error uploading photo');
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  void _saveProfile() async {
    final String gender;
    switch (_genderKind) {
      case GenderKind.man:
        gender = 'man';
        break;
      case GenderKind.woman:
        gender = 'woman';
        break;
      case GenderKind.nonbinary:
        gender = (_genderIdentity == null || _genderIdentity!.trim().isEmpty) ? 'nonbinary' : _genderIdentity!;
        break;
    }

    try {
      await AuthService.instance.updateProfile(
        _name,
        _bio,
        gender,
        _relationshipInterests,
        _neurodiversities,
        _interests,
        _pronouns,
        RequestsService.instance
      );

      if (!mounted) return;
      textSnackbar(context, 'Successfully updated profile');
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Error updating profile');
    }
  }
}
