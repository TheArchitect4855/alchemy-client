import 'package:alchemy/components/number_badge.dart';
import 'package:alchemy/pages/chat.dart';
import 'package:flutter/material.dart';
import 'package:alchemy/data/match.dart';

class MatchesPage extends StatelessWidget {
  final Future<List<Match>>? matchesFuture;
  final void Function() onUpdate;

  const MatchesPage(this.matchesFuture, {required this.onUpdate, super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: matchesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final theme = Theme.of(context);
        if (snapshot.hasError) {
          return Center(
              child: Column(children: [
            const Text('Error getting matches:', textAlign: TextAlign.center),
            Text(snapshot.error?.toString() ?? 'No further information',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!
                    .apply(color: theme.colorScheme.error)),
          ]));
        }

        final matches = snapshot.data!;
        if (matches.isEmpty) {
          return const Center(child: Text('No matches yet! \u{1f997}'));
        }

        return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, i) {
              final theme = Theme.of(context);
              final match = matches[i];
              final info = [
                Text(match.profile.name, style: theme.textTheme.headlineMedium)
              ];
              if (match.lastMessage != null) {
                final from =
                    match.lastMessage!.isLocal ? 'You' : match.profile.name;
                info.add(Text(
                  '$from: ${match.lastMessage!.content}',
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ));
              }

              final size = MediaQuery.of(context).size;
              final badges = <Widget>[];
              for (final interaction in match.interactions) {
                badges.add(Image.asset(
                  interaction.getIconFile(),
                  height: 16,
                  fit: BoxFit.contain,
                ));
              }

              if (match.numUnread > 0) badges.add(NumberBadge(number: match.numUnread));

              return InkWell(
                onTap: () => _openMessages(context, match),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(match.profile.photoUrls[0]),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(width: 64, height: 64),
                      ),
                      const SizedBox(width: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width - 192),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: info,
                        ),
                      ),
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: badges,
                        ),
                      )),
                    ],
                  ),
                ),
              );
            });
      });

  void _openMessages(BuildContext context, Match match) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ChatPage(match.profile)));
    onUpdate();
  }
}
