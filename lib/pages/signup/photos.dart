import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/components/photo_upload_button.dart';
import 'package:alchemy/components/profile_photo.dart';
import 'package:alchemy/components/small_card.dart';
import 'package:alchemy/data/preferences.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/error.dart';
import 'package:alchemy/pages/locationrequest.dart';
import 'package:alchemy/pages/signup/tos.dart';
import 'package:alchemy/routing.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/photos.dart';
import 'package:alchemy/services/preferences.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';

class SignupPhotosPage extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const SignupPhotosPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupPhotosPageState();
}

class _SignupPhotosPageState extends State<SignupPhotosPage> {
  final List<Future<String>> _photos = [];
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    if (AuthService.instance.profile == null && widget.profileData != null) {
      _createProfile();
    } else {
      _isReady = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MultiPageBottomCard(
        title: 'Add Photos',
        next: null,
        children: [
          CircularProgressIndicator(),
        ],
      );
    }

    final photos = _getPhotoWidgets();
    if (photos.length < PhotosService.maxPhotoCount) {
      photos.add(PhotoUploadButton(
        onUploadStart: (urlFuture) => setState(() {
          _photos.add(urlFuture);
        }),
      ));
    }

    return MultiPageBottomCard(
      alignment: CrossAxisAlignment.stretch,
      title: 'Add Photos',
      next: _photos.isEmpty ? null : const SignupTosPage(),
      children: [
        const Text(
            'You must have at least one photo to complete your profile.'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: photos,
        ),
      ],
    );
  }

  void _createProfile() async {
    try {
      final p = widget.profileData!;
      await PreferencesService.instance.setPreferences(
          Preferences(
            true,
            p['showTransgender'],
            p['genderInterests'],
          ),
          RequestsService.instance);

      final profile = await AuthService.instance.createProfile(
        p['name'],
        p['bio'],
        p['gender'],
        p['relationshipInterests'],
        p['neurodiversities'],
        p['interests'],
        p['pronouns'],
        LocationService.instance,
        RequestsService.instance,
        isTransgender: p['isTransgender'],
      );

      Logger.debug(runtimeType, profile.toString());
      setState(() {
        _isReady = true;
      });
    } on LocationServicePermissionException {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LocationRequestPage()));
    } on Exception catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
    }
  }

  List<Widget> _getPhotoWidgets() => _photos
      .map((e) => FutureBuilder(
            future: e,
            builder: (context, snapshot) {
              final theme = Theme.of(context);
              if (snapshot.hasData) {
                return ProfilePhoto(
                  photoUrl: snapshot.data!,
                  onRemove: () => setState(() {
                    _photos.remove(e);
                    PhotosService.instance
                        .removePhoto(snapshot.data!, RequestsService.instance);
                  }),
                );
              } else if (snapshot.hasError) {
                if (snapshot.error is RequestsServiceHttpException) {
                  _onError(snapshot.error as Exception);
                }

                return SmallCard(
                    child: Icon(Icons.error_outline,
                        color: theme.colorScheme.error));
              } else {
                return const SmallCard(
                    child: Center(child: CircularProgressIndicator()));
              }
            },
          ))
      .cast<Widget>()
      .toList();

  void _onError(Exception e) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => replaceRoute(context, ErrorPage(message: e.toString())));
  }
}
