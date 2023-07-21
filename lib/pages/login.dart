import 'package:alchemy/components/bigbutton.dart';
import 'package:alchemy/components/bottomcard.dart';
import 'package:alchemy/components/phoneinput.dart';
import 'package:alchemy/data/phonenumber.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/logincode.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isBusy = false;
  bool _useWhatsApp = false;
  String? _errorText;
  PhoneNumber? _phoneNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomCard(
      title: 'Log In',
      children: [
        PhoneNumberInput(
            onChanged: (v) => setState(() {
                  _phoneNumber = v;
                })),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Text('Text me via WhatsApp'),
          Switch(
            value: _useWhatsApp,
            onChanged: (v) => setState(() {
              _useWhatsApp = v;
            }),
          ),
        ]),
        const SizedBox(height: 16),
        BigButton(text: 'NEXT', onPressed: (_isBusy || _phoneNumber == null) ? null : _logIn),
        _errorText == null
            ? const SizedBox(height: 20)
            : Text(_errorText!,
                style: theme.textTheme.bodyMedium!
                    .apply(color: theme.colorScheme.error),
                textAlign: TextAlign.center),
        Text(
            'Don’t have an account? No problem! Enter your phone number and we’ll create one for you.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center),
      ],
    );
  }

  void _logIn() async {
    if (_phoneNumber == null) {
      setState(() {
        _errorText = 'Please enter a phone number.';
      });

      return;
    }

    setState(() {
      _errorText = null;
      _isBusy = true;
    });

    String? errorText;
    try {
      final requestsService = RequestsService.instance;
      final channel =
          _useWhatsApp ? LoginCodeChannel.whatsapp : LoginCodeChannel.sms;
      await AuthService.instance
          .requestLoginCode(_phoneNumber!, channel, requestsService);
      if (!mounted) {
        Logger.error(runtimeType, 'Context was unmounted!');
        return;
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LoginCodePage(phoneNumber: _phoneNumber!, channel: channel)));
    } on RequestsServiceClientException catch (e) {
      Logger.warnException(runtimeType, e);
      errorText = 'Network error.';
    } on RequestsServiceHttpException catch (e) {
      errorText = '${e.error}.';
    } on RequestsServiceTimeoutException {
      errorText = 'Request timed out.';
    } on Exception catch (e) {
      Logger.exception(runtimeType, e);
      errorText = 'An unknown error occured.';
    } finally {
      setState(() {
        _errorText = errorText;
        _isBusy = false;
      });
    }
  }
}
