import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/pages/signup/neurodiversities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupBioPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SignupBioPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupBioPageState();
}

class _SignupBioPageState extends State<SignupBioPage> {
  @override
  Widget build(BuildContext context) {
    return MultiPageBottomCard(
      title: 'Tell us about yourself...',
      next: SignupNeurodiversitiesPage(profileData: widget.profileData),
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Bio',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            helperText: 'This can be changed at any time. You can also leave it blank.',
            helperMaxLines: 3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textInputAction: TextInputAction.newline,
          maxLength: 1000,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          maxLines: 5,
          onChanged: (v) => setState(() {
            widget.profileData['bio'] = v;
          }),
        ),
      ],
    );
  }
}
