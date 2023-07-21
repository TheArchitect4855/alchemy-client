import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChipSelector extends StatelessWidget {
  final String label;
  final String? helperText;
  final List<String> options;
  final Set<String> selected;
  final void Function(List<String>, Set<String>) onChanged;
  final bool allowOther;
  final int? maxSelections;

  const ChipSelector(
      {required this.label,
      required this.options,
      required this.selected,
      required this.onChanged,
      this.helperText,
      this.maxSelections,
      this.allowOther = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMax = maxSelections != null && selected.length >= maxSelections!;
    final List<Widget> chips = options
        .map((e) => FilterChip(
              label: Text(e),
              selected: selected.contains(e),
              onSelected: (isMax && !selected.contains(e))
                  ? null
                  : (isSelected) {
                      if (isSelected) {
                        selected.add(e);
                      } else {
                        selected.remove(e);
                      }

                      onChanged(options, selected);
                    },
            ))
        .cast<Widget>()
        .toList();

    if (allowOther) {
      chips.add(ActionChip(
        avatar: Icon(Icons.add, color: theme.colorScheme.onBackground),
        label: const Text('Other'),
        onPressed: isMax ? null : () => _addOther(context),
      ));
    }

    final children = <Widget>[
      Text(label, style: theme.textTheme.labelMedium),
      Wrap(
        spacing: 8,
        children: chips,
      ),
    ];

    if (helperText != null) {
      children.add(
        Text(helperText!, style: theme.textTheme.labelMedium),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _addOther(BuildContext context) async {
    String? selection;
    selection = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Other'),
        content: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textInputAction: TextInputAction.done,
          maxLength: 30,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: (v) => selection = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selection),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (selection != null) {
      options.add(selection!);
      selected.add(selection!);
      onChanged(options, selected);
    }
  }
}
