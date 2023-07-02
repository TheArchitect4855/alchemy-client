import 'dart:async';
import 'package:alchemy/components/bigbutton.dart';
import 'package:alchemy/components/bottomcard.dart';
import 'package:alchemy/data/phonenumber.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/init.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const codeLength = 6;
const resendCountdownSeconds = 30;

class LoginCodePage extends StatefulWidget {
  final PhoneNumber phoneNumber;
  final LoginCodeChannel channel;

  const LoginCodePage({required this.phoneNumber, required this.channel, super.key});

  @override
  State<StatefulWidget> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {
  bool _isBusy = false;
  int _countdown = resendCountdownSeconds;
  String? _code;
  String? _codeErrorText;
  String? _errorText;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomCard(
      title: 'Log In', 
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Login Code',
            helperText: 'We\'ve sent a code to ${widget.phoneNumber}.',
            errorText: _codeErrorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.center,
          maxLength: codeLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: (v) => setState(() {
            _code = v;
          }),
        ),
        const SizedBox(height: 16),
        BigButton(text: 'LOG IN', onPressed: _isBusy ? null : _logIn),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(theme.colorScheme.secondary)),
          child: const Text('Back'),
        ),
        _errorText == null ? const SizedBox(height: 20) : Text(_errorText!, style: theme.textTheme.bodyMedium!.apply(color: theme.colorScheme.error)),
        Text(_countdown > 0 ? 'Resend Code (${_countdown}s)' : 'Resend Code'),
        const SizedBox(height: 8),
        IconButton.filled(
          onPressed: _countdown <= 0 ? _resendCode : null,
          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            } else {
              return theme.colorScheme.secondary;
            }
          })),
          icon: const Icon(Icons.sync),
        ),
      ],
    );
  }

  void _logIn() async {
    if (_code == null || _code!.length != codeLength) {
      setState(() {
        _codeErrorText = 'Login code must be 6 characters.';
      });

      return;
    }

    setState(() {
      _isBusy = true;
      _codeErrorText = null;
      _errorText = null;
    });

    String? errorText;
    try {
      final requestsService = RequestsService.instance;
      await AuthService.instance.login(widget.phoneNumber, _code!, requestsService);
      if (!mounted) {
        Logger.error(runtimeType, 'Context was unmounted!');
        return;
      }

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const InitPage()), (_) => false);
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resendCode() async {
    setState(() {
      _isBusy = true;
      _countdown = resendCountdownSeconds;
    });

    String? errorText;
    try {
      final requestsService = RequestsService.instance;
      await AuthService.instance.requestLoginCode(widget.phoneNumber, widget.channel, requestsService);
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

  void _tick(Timer timer) {
    if (_countdown > 0) {
      setState(() {
        _countdown -= 1;
      });
    }
  }
}
