import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WideTextField extends StatefulWidget {
  final String defaultValue;
  final String? labelText;
  final int? maxLength;
  final int? maxLines;
  final void Function(String value)? onChanged;

  const WideTextField({required this.defaultValue, this.labelText, this.maxLength, this.maxLines = 1, this.onChanged, super.key});

  @override
  State<StatefulWidget> createState() => _WideTextFieldState();
}

class _WideTextFieldState extends State<WideTextField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.text = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: widget.labelText,
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLength: widget.maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
