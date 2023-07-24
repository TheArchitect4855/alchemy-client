import 'package:alchemy/components/confirmationdialog.dart';
import 'package:alchemy/components/labeled_checkbox.dart';
import 'package:alchemy/data/preferences.dart';
import 'package:alchemy/gender_kind.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/init.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/notifications.dart';
import 'package:alchemy/services/preferences.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/snackbar_util.dart';
import 'package:flutter/material.dart';

import '../components/chipselector.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<StatefulWidget> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final PreferencesService _preferencesService = PreferencesService.instance;
  final RequestsService _requestsService = RequestsService.instance;
  late Future<Preferences> _preferencesFuture;
  bool _isDirty = false;
  Preferences? _preferences;

  @override
  void initState() {
    super.initState();
    _preferencesFuture = _preferencesService.getPreferences(_requestsService);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: FutureBuilder(
          future: _preferencesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _preferences ??= snapshot.data!;
              return _buildPreferences(context);
            } else if (snapshot.hasError) {
              if (snapshot.error is Exception)
                Logger.warnException(runtimeType, snapshot.error as Exception);

              return Column(children: [
                const Text('Error getting preferences:'),
                Text(snapshot.error.toString()),
              ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget _buildPreferences(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              LabeledCheckbox(
                label: const Text('Allow notifications'),
                value: _preferences!.allowNotifications &&
                    NotificationsService.instance.isEnabled,
                onChanged: _setAllowNotifications,
              ),
              LabeledCheckbox(
                label: const Text('Show transgender people in my feed'),
                value: _preferences!.showTransgender,
                onChanged: (v) => setState(() {
                  _preferences = _preferences!.copyWith(showTransgender: v);
                  _isDirty = true;
                }),
              ),
              ChipSelector(
                label: 'Show Me',
                options: const [
                  'Men',
                  'Non-Binary',
                  'Women',
                ],
                selected:
                    _preferences!.genderInterests.map(parseGenderKind).toSet(),
                onChanged: (_, selected) => setState(() {
                  if (selected.isEmpty) return;
                  _preferences = _preferences!.copyWith(
                      genderInterests: selected.map(parseGenderName).toSet());
                  _isDirty = true;
                }),
              ),
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
              TextButton.icon(
                onPressed: _deleteProfile,
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStatePropertyAll(theme.colorScheme.error),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Profile'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProfile() async {
    final nav = Navigator.of(context);
    final confirm = await const ConfirmationDialog(
      action: 'Delete Profile',
      detail:
          'You will not appear in other people\'s explore feeds and all of your profile information will be lost. THIS CANNOT BE UNDONE.',
      confirm: 'Delete my Profile',
    ).show(context);

    if (!confirm) return;

    try {
      await AuthService.instance.deleteProfile(_requestsService);
      nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const InitPage()),
          (route) => false);
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      if (mounted) textSnackbar(context, 'Error deleting profile');
    }
  }

  Future<void> _logout() async {
    try {
      final nav = Navigator.of(context);
      await AuthService.instance.logout(_requestsService);
      nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const InitPage()),
          (route) => false);
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      if (mounted) textSnackbar(context, 'Error logging out');
    }
  }

  Future<void> _save() async {
    try {
      if (_isDirty) {
        await _preferencesService.setPreferences(
            _preferences!, _requestsService);
      }

      setState(() {
        _isDirty = false;
      });

      if (mounted) textSnackbar(context, 'Preferences saved!');
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Error saving preferences');
    }
  }

  void _setAllowNotifications(bool value) async {
    final notifications = NotificationsService.instance;
    if (value && !notifications.isEnabled) {
      await notifications.requestPermissions();
    }

    setState(() {
      _preferences = _preferences!
          .copyWith(allowNotifications: value && notifications.isEnabled);
      _isDirty = true;
    });
  }
}
