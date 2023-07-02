import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/pages/signup/bio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupPronounsPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SignupPronounsPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupPronounsPageState();
}

class _SignupPronounsPageState extends State<SignupPronounsPage> {
  @override
  Widget build(BuildContext context) {
    return MultiPageBottomCard(
      title: 'Tell us about yourself...',
      next: SignupBioPage(profileData: widget.profileData),
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Pronouns',
            helperText: 'This can be changed at any time. You can also leave it blank.',
            helperMaxLines: 3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textInputAction: TextInputAction.next,
          maxLength: 30,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: (v) => setState(() {
            widget.profileData['pronouns'] = v;
          }),
        ),
      ],
    );
  }
}
