import 'package:flutter/material.dart';

class DateInput extends StatefulWidget {
  final String label;
  final String helperText;
  final void Function(DateTime) onSubmit;

  const DateInput({required this.label, required this.helperText, required this.onSubmit, super.key});
  
  @override
  State<StatefulWidget> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    if (_value != null) _textController.text = _formatDate(_value!);
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        helperText: widget.helperText,
        helperMaxLines: 3,
        hintText: 'DD/MM/YYYY',
        suffixIcon: const Icon(Icons.event),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      readOnly: true,
      onTap: () => _showDatePicker(context),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';

  void _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final v = await showDatePicker(context: context, initialDate: _value ?? now, firstDate: DateTime(1900), lastDate: now);
    if (v != null) {
      setState(() {
        _value = v;
      });

      widget.onSubmit(v);
    }
  }
}
