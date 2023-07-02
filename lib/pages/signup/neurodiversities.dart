import 'package:alchemy/components/chipselector.dart';
import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/pages/signup/interests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupNeurodiversitiesPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SignupNeurodiversitiesPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupNeurodiversitiesPageState();
}

class _SignupNeurodiversitiesPageState extends State<SignupNeurodiversitiesPage> {
  late Future<String> _dataFuture;
  List<String>? _neurodiversities;
  Set<String> _selectedNeurodiversities = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = rootBundle.loadString('assets/neurodiversities.txt');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder: _futureBuilder,
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot<String> snapshot) {
    final theme = Theme.of(context);
    final errorStyle = theme.textTheme.bodyMedium!.apply(color: theme.colorScheme.error);
    List<Widget> children;
    if (snapshot.hasData) {
      _neurodiversities ??= snapshot.data!.split('\n').map((e) => e.trim()).toList();
      _neurodiversities!.sort();

      children = [
        ChipSelector(
          label: 'Neurodiversities to Display',
          helperText: 'Select as many or as few as you’d like. These will be shown on your profile and can be changed at any time.',
          options: _neurodiversities!,
          selected: _selectedNeurodiversities,
          onChanged: (options, selected) => setState(() {
            _neurodiversities = options;
            _selectedNeurodiversities = selected;
            widget.profileData['neurodiversities'] = selected;
          }),
          allowOther: true,
        ),
      ];
    } else if (snapshot.hasError) {
      children = [
        Text('An error occurred:', style: errorStyle),
        Text(snapshot.error?.toString() ?? 'No further information', style: errorStyle),
      ];
    } else {
      children = [
        const CircularProgressIndicator(),
      ];
    }

    return MultiPageBottomCard(
      title: 'Tell us about yourself...',
      next: SignupInterestsPage(profileData: widget.profileData),
      children: children,
    );
  }
}
