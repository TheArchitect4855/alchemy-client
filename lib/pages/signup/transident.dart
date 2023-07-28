import 'package:alchemy/components/labeled_checkbox.dart';
import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/pages/signup/photos.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupTransgenderSelfIdentificationPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SignupTransgenderSelfIdentificationPage({required this.profileData, super.key});

  @override
  State<StatefulWidget> createState() => _SignupTransgenderSelfIdentificationPageState();
}

class _SignupTransgenderSelfIdentificationPageState extends State<SignupTransgenderSelfIdentificationPage> {
  bool _isTrans = false;
  bool _showTrans = true;

  @override
  Widget build(BuildContext context) {
    widget.profileData['isTransgender'] = _isTrans;
    widget.profileData['showTransgender'] = _showTrans;

    return MultiPageBottomCard(
      title: 'Transgender self-identification',
      next: SignupPhotosPage(profileData: widget.profileData),
      children: [
        const Text(
          'Alchemy aims to be an inclusive platform for everyone. To make using Alchemy more comfortable and safe for transgender individuals, you may disclose whether or not you are transgender and whether or not you would like to see transgender people in your feed. This information WILL NOT be displayed on your profile, and is completely optional.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LabeledCheckbox(
          label: const Text('I am transgender'),
          value: _isTrans,
          onChanged: (v) => setState(() {
            _isTrans = v;
          }),
        ),
        LabeledCheckbox(
          label: const Text('Show transgender people in my feed'),
          value: _showTrans,
          onChanged: (v) => setState(() {
            _showTrans = v;
          }),
        ),
        TextButton(
          child: const Text('View Alchemy\'s Privacy Policy'),
          onPressed: () => launchUrl(
            Uri.parse('https://usealchemy.app/legal/privacy'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}
