import 'package:alchemy/components/chipselector.dart';
import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/gender_kind.dart';
import 'package:alchemy/pages/signup/transident.dart';
import 'package:flutter/material.dart';

const relationshipInterestsMap = {
  'Friends': 'friends',
  'Flings': 'flings',
  'Romance': 'romance',
};

class SignupDatingPreferencesPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SignupDatingPreferencesPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupDatingPreferencesPageState();
}

class _SignupDatingPreferencesPageState extends State<SignupDatingPreferencesPage> {
  Set<String> _genderInterests = { 'Men', 'Non-Binary', 'Women' };
  Set<String> _relationshipInterests = {};
  GenderKind? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const Text('I am...'),
      const SizedBox(height: 8),
      SegmentedButton(
        segments: const [
          ButtonSegment(value: GenderKind.man, label: Text('A Man')),
          ButtonSegment(value: GenderKind.nonbinary, label: Text('Non-Binary')),
          ButtonSegment(value: GenderKind.woman, label: Text('A Woman')),
        ],
        selected: { _selectedGender },
        onSelectionChanged: (v) => setState(() {
          _selectedGender = v.first;
          widget.profileData['gender'] = v.first!.name;
        }),
      ),
    ];

    if (_selectedGender == GenderKind.nonbinary) {
      children.addAll([
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Gender',
            helperText: 'This will be shown on your profile and can be changed at any time. You can also leave it blank.',
            helperMaxLines: 3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (v) => setState(() {
            widget.profileData['gender'] = v;
          }),
        ),
      ]);
    }

    children.addAll([
      const SizedBox(height: 32),
      ChipSelector(
        label: 'I’m interested in...',
        options: const [
          'Men',
          'Non-Binary',
          'Women',
        ],
        selected: _genderInterests,
        onChanged: (_, selected) => setState(() {
          if (selected.isEmpty) return;
          _genderInterests = selected;
          widget.profileData['genderInterests'] = selected.map(parseGenderName).toSet();
        }),
      ),
      const SizedBox(height: 32),
      ChipSelector(
        label: 'I’m looking for...',
        options: const [
          'Flings',
          'Friends',
          'Romance',
        ],
        selected: _relationshipInterests,
        onChanged: (_, selected) => setState(() {
          _relationshipInterests = selected;
          widget.profileData['relationshipInterests'] = selected.map((e) => relationshipInterestsMap[e]!).toSet();
        }),
      ),
    ]);

    return MultiPageBottomCard(
      alignment: CrossAxisAlignment.stretch,
      title: 'Tell us about yourself...',
      next: _selectedGender == null || _genderInterests.isEmpty || _relationshipInterests.isEmpty ? null : SignupTransgenderSelfIdentificationPage(profileData: widget.profileData),
      children: children,
    );
  }
}
