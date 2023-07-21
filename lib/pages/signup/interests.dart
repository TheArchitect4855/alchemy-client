import 'package:alchemy/components/chipselector.dart';
import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/pages/signup/datingpreferences.dart';
import 'package:alchemy/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupInterestsPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SignupInterestsPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupInterestsPageState();
}

class _SignupInterestsPageState extends State<SignupInterestsPage> {
  late Future<String> _dataFuture;
  Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = rootBundle.loadString('assets/interests.txt');
    widget.profileData['interests'] = _selectedInterests;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder: _buildFuture,
    );
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot<String> snapshot) {
    final theme = Theme.of(context);
    final errorStyle =
        theme.textTheme.bodyMedium!.apply(color: theme.colorScheme.error);
    List<Widget> children;
    if (snapshot.hasData) {
      final options = snapshot.data!.split('\n').map((e) => e.trim()).toList();
      options.sort();
      children = [
        ChipSelector(
          label: 'Interests',
          helperText:
              'Select as many or as few as you’d like. These will be shown on your profile and can be changed at any time.',
          options: options,
          selected: _selectedInterests,
          maxSelections: AuthService.maxTags,
          onChanged: (options, selected) => setState(() {
            _selectedInterests = selected;
            widget.profileData['interests'] = selected;
          }),
        ),
      ];
    } else if (snapshot.hasError) {
      children = [
        Text('An error occurred:', style: errorStyle),
        Text(snapshot.error?.toString() ?? 'No further information',
            style: errorStyle),
      ];
    } else {
      children = [
        const CircularProgressIndicator(),
      ];
    }

    return MultiPageBottomCard(
      title: 'Tell us about yourself...',
      next: SignupDatingPreferencesPage(profileData: widget.profileData),
      children: children,
    );
  }
}
