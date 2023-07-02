import 'package:alchemy/components/number_badge.dart';
import 'package:alchemy/data/message.dart';
import 'package:alchemy/pages/chat.dart';
import 'package:flutter/material.dart';
import 'package:alchemy/data/match.dart';

class MatchesPage extends StatelessWidget {
  final List<Match>? matches;
  final void Function(Match match) onMarkRead;
  final void Function(Match match, Message message) onMessage;
  final void Function(Match match) onUnmatch;

  const MatchesPage(this.matches, {required this.onMarkRead, required this.onMessage, required this.onUnmatch, super.key});

  @override
  Widget build(BuildContext context) {
    if (matches == null) return const Center(child: CircularProgressIndicator());
    if (matches!.isEmpty) return const Center(child: Text('No matches yet! \u{1f997}'));

    return ListView.builder(
      itemCount: matches!.length,
      itemBuilder: (context, i) {
        final theme = Theme.of(context);
        final match = matches![i];
        final info = [ Text(match.profile.name, style: theme.textTheme.headlineMedium) ];
        if (match.lastMessage != null) {
          final from = match.lastMessage!.isLocal ? 'You' : match.profile.name;
          info.add(Text(
            '$from: ${match.lastMessage!.content}',
            style: theme.textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ));
        }

        final size = MediaQuery.of(context).size;
        return InkWell(
          onTap: () => _openMessages(context, match),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                Expanded(child: Align(
                  alignment: Alignment.centerRight,
                  child: match.numUnread > 0 ? NumberBadge(number: match.numUnread) : null,
                )),
              ],
            ),
          ),
        );
      }
    );
  }

  void _openMessages(BuildContext context, Match match) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(
      match.profile,
      onMessage: (v) => onMessage(match, v),
      onUnmatch: () => onUnmatch(match),
    )));

    onMarkRead(match);
  }
}
