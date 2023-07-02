import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  final Widget label;
  final bool value;
  final void Function(bool value) onChanged;

  const LabeledCheckbox({required this.label, required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return theme.colorScheme.secondary.withOpacity(0.5);
            } else {
              return theme.colorScheme.onBackground.withOpacity(0.6);
            }
          }),
          splashRadius: 0,
        ),
        label,
      ],
    );
  }
}
