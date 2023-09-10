import 'package:alchemy/data/callingcode.dart';
import 'package:alchemy/data/phonenumber.dart';
import 'package:flutter/material.dart';

const formatErrorMessage = 'Please enter a phone number in E.123 international format (e.g. +1 234 567 8910).';

class PhoneNumberInput extends StatefulWidget {
  final void Function(PhoneNumber? phone) onChanged;

  const PhoneNumberInput({required this.onChanged, super.key});

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  String? _errorText;
  CallingCode? _callingCode;
  ImageProvider<Object>? _flag;
  bool _isPhoneValid = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textController.addListener(_onInputChanged);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        helperText: 'We\'ll send you a text with your login code.',
        errorText: _errorText,
        errorMaxLines: 3,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: _callingCode == null ? null : Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(image: _flag!),
              const SizedBox(width: 8),
              Text(_callingCode!.dialCode, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done, 
      onChanged: (v) {
        if (_isPhoneValid) {
          widget.onChanged(PhoneNumber(_callingCode!, v.substring(1)));
        } else {
          widget.onChanged(null);
        }
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_textController.text.isEmpty) {
      setState(() {
        _callingCode = null;
        _isPhoneValid = false;
        _textController.text = '+';
        _errorText = formatErrorMessage;
      });

      return;
    }

    CallingCode? cc = PhoneNumber.parseCallingCode(_textController.text);
    if (_callingCode == null && cc == null) {
      setState(() {
        _errorText = _textController.text.startsWith('+') ? null : formatErrorMessage;
        _isPhoneValid = false;
      });

      return;
    } else if (cc != null) {
      final suffix = _textController.text.substring(cc.dialCode.length);

      // Prefix text input with zero-width space to represent the calling code
      _textController.value = _textController.value.copyWith(text: '\u{200B}$suffix', selection: TextSelection.collapsed(offset: suffix.length + 1), composing: TextRange.empty);
      setState(() {
        _errorText = null;
        _callingCode = cc;
        _flag = AssetImage('assets/flags/${cc.code.toLowerCase()}.png');
        _isPhoneValid = false;
      });

      return;
    }

    // Phone number is valid
    final suffix = _textController.text.substring(1);
    final isValidSuffix = PhoneNumber.isValidSuffix(suffix);
    setState(() {
      _errorText = isValidSuffix ? null : formatErrorMessage;
      _isPhoneValid = isValidSuffix;
    });
  }
}
