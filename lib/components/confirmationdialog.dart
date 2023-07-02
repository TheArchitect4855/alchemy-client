import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String action;
  final String detail;
  final String cancel;
  final String confirm;

  const ConfirmationDialog({required this.action, required this.detail, this.cancel = 'Cancel', this.confirm = 'Ok', super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('$action?'),
    content: Text(detail),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(confirm),
      ),
    ],
  );

  Future<bool> show(BuildContext context) async {
    final res = await showDialog(context: context, builder: (_) => this);
    return res ?? false;
  }
}
