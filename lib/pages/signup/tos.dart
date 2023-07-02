import 'package:alchemy/components/labeled_checkbox.dart';
import 'package:alchemy/components/multipage_bottomcard.dart';
import 'package:alchemy/pages/signup/finalize.dart';
import 'package:flutter/material.dart';

class SignupTosPage extends StatefulWidget {
  const SignupTosPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupTosPageState();
}

class _SignupTosPageState extends State<SignupTosPage> {
  bool _agreeTos = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bold = theme.textTheme.bodyMedium!  .apply(fontWeightDelta: 10);
    return MultiPageBottomCard(
      title: 'One last thing...',
      next: _agreeTos ? const SignupFinalizePage() : null,
      children: [
        LabeledCheckbox(
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'I agree to Alchemy’s ',
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(text: 'Terms of Service\n', style: bold),
                  const TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Policy', style: bold),
                ],
              ),
            ),
          ),
          value: _agreeTos,
          onChanged: (v) => setState(() {
            _agreeTos = v;
          }),
        )
      ],
    );
  }
}
