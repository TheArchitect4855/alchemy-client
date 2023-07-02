import 'package:flutter/material.dart';

class BottomCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  const BottomCard({required this.title, required this.children, this.crossAxisAlignment = CrossAxisAlignment.center, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: HSVColor.fromColor(theme.colorScheme.primary).withSaturation(0.35).toColor(),
          image: const DecorationImage(
            image: AssetImage('assets/plants-bg.png'),
            fit: BoxFit.none,
            scale: 1.5,
            opacity: 0.5,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(minHeight: screenSize.height * 0.7, minWidth: screenSize.width, maxWidth: screenSize.width),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: [
                Image.asset(
                  'assets/icon.png',
                  height: 130,
                ),
                Text(title, style: theme.textTheme.displaySmall, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
