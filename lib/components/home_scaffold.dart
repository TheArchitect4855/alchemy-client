import 'package:flutter/material.dart';
import 'number_badge.dart';

class HomeScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final int messageNotificationBadge;
  final void Function(int)? onNavTapped;
  final void Function()? onSettingsPressed;
  final Future<bool> Function()? onWillPop;

  const HomeScaffold(
      {required this.body,
      required this.currentIndex,
      required this.messageNotificationBadge,
      required this.onNavTapped,
      required this.onSettingsPressed,
      required this.onWillPop,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/icon-crop.png'),
          ),
          title: Text('alchemy', style: theme.textTheme.titleLarge!.apply(color: theme.colorScheme.primary)),
          actions: [
            IconButton(
              color: Colors.black38,
              onPressed: onSettingsPressed,
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: 'Explore',
              activeIcon: Icon(Icons.explore),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
              activeIcon: Icon(Icons.account_circle),
            ),
            BottomNavigationBarItem(
              icon: messageNotificationBadge > 0
                  ? NumberBadge(number: messageNotificationBadge, child: const Icon(Icons.message_outlined))
                  : const Icon(Icons.message_outlined),
              label: 'Messages',
              activeIcon: const Icon(Icons.message),
            ),
          ],
          onTap: onNavTapped,
          currentIndex: currentIndex,
          useLegacyColorScheme: false,
        ),
      ),
    );
  }
}
