import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black45,
        title: const Text('Something went wrong.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('An error has occured.', style: theme.textTheme.titleMedium),
            const Text('This isn\'t your fault; something broke internally.'),
            const Text('Try restarting the app, and if this issue persists please file a bug with the developers.'),
            const SizedBox(height: 24),
            const Text('Details:'),
            Text(message, style: theme.textTheme.bodySmall!.apply(color: theme.colorScheme.error)),
          ],
        ),
      ),
    );
  }
}
