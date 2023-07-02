import 'package:alchemy/components/bigbutton.dart';
import 'package:alchemy/components/bottomcard.dart';
import 'package:alchemy/components/dateinput.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/error.dart';
import 'package:alchemy/pages/noconnection.dart';
import 'package:alchemy/pages/redlisted.dart';
import 'package:alchemy/pages/signup/pronouns.dart';
import 'package:alchemy/routing.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupIntakePage extends StatefulWidget {
  const SignupIntakePage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupIntakePageState();
}

class _SignupIntakePageState extends State<SignupIntakePage> {
  String? _name;
  DateTime? _birthday;

  @override
  Widget build(BuildContext context) {
    return BottomCard(
      title: 'Create Profile',
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Name',
            helperText: 'This will be shown on your profile and can be changed at any time.',
            helperMaxLines: 3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
          ),
          textInputAction: TextInputAction.next,
          maxLength: 100,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: (v) => setState(() {
            _name = v;
          }),
        ),
        const SizedBox(height: 16),
        DateInput(
          label: 'Birthday',
          helperText: 'This cannot be changed. Your age can optionally be shown on your profile.',
          onSubmit: (v) => setState(() {
            _birthday = v;
          }),
        ),
        const SizedBox(height: 16),
        BigButton(text: 'NEXT', onPressed: (_name == null || _birthday == null) ? null : _onNext),
      ],
    );
  }

  Future<bool> _createContact() async {
    try {
      final contact = await AuthService.instance.createContact(_birthday!, RequestsService.instance);
      if ((contact.isRedlisted || contact.age < 18) && mounted) {
        replaceRoute(context, const RedlistedPage());
        return false;
      } else if (!mounted) {
        Logger.error(runtimeType, 'Context was unmounted!');
        return false;
      }
    } on RequestsServiceHttpException catch (e) {
      AuthService.instance.logout(RequestsService.instance); // Log out in case there's some sort of weird desync goin on
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
      return false;
    } on RequestsServiceException catch (e) {
      Logger.warnException(runtimeType, e);
      replaceRoute(context, const NoConnectionPage());
      return false;
    }

    return true;
  }

  void _onNext() async {
    final authService = AuthService.instance;
    if (authService.contact == null) {
      final ok = await _createContact();
      if (!ok) return;
    }

    if (!mounted) {
      Logger.error(runtimeType, 'Context was unmounted!');
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPronounsPage(profileData: { 'name': _name })));
  }
}
