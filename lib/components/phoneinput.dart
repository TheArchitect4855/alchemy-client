import 'package:alchemy/data/callingcode.dart';
import 'package:alchemy/data/phonenumber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const formatErrorMessage = 'Please enter a phone number in E.123 international format (e.g. +1 234 567 8910).';

class PhoneNumberInput extends StatefulWidget {
  final void Function(PhoneNumber phone) onChanged;

  const PhoneNumberInput({required this.onChanged, super.key});

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  String? errorText;
  CallingCode? _callingCode;
  ImageProvider<Object>? _flag;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_onKeyboard);
    _textController.addListener(() {
      if (_textController.text.isEmpty) return;

      CallingCode? callingCode = PhoneNumber.parseCallingCode(_textController.text);
      bool isValidSuffix = PhoneNumber.isValidSuffix(_textController.text);
      if (callingCode == null && (_callingCode == null || !isValidSuffix) && _textController.text.length > 1) {
        setState(() {
          errorText = formatErrorMessage;
        });
      } else if (callingCode != null) {
        final suffix = _textController.text.substring(callingCode.dialCode.length);
        _textController.value = _textController.value.copyWith(text: suffix, selection: TextSelection.collapsed(offset: suffix.length), composing: TextRange.empty);
        setState(() {
          errorText = null;
          _callingCode = callingCode;
          _flag = AssetImage('assets/flags/${_callingCode!.code.toLowerCase()}.png');
        });
      } else if (isValidSuffix) {
        setState(() {
          errorText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        helperText: 'We\'ll send you a text with your login code.',
        errorText: errorText,
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
        if (_callingCode == null || !PhoneNumber.isValidSuffix(v)) {
          setState(() {
            errorText = formatErrorMessage;
          });

          return;
        }

        widget.onChanged(PhoneNumber(_callingCode!, v));
      },
    );
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onKeyboard);
    _textController.dispose();
    super.dispose();
  }

  void _onKeyboard(RawKeyEvent e) {
    if (e.logicalKey == LogicalKeyboardKey.backspace && _textController.text.isEmpty) {
      setState(() {
        _callingCode = null;
      });
    }
  }
}
