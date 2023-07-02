import 'package:alchemy/data/message.dart';
import 'package:alchemy/data/profile.dart';

class Match {
  final Profile profile;
  final Message? lastMessage;
  final int numUnread;

  Match(this.profile, this.lastMessage, this.numUnread);
  Match.fromJson(Map<String, dynamic> values) : this(
    Profile.fromJson(values['profile']),
    values['lastMessage'] == null ? null : Message.fromJson(values['lastMessage']),
    values['numUnread']
  );

  Match copyWith({
    Profile? profile,
    Message? lastMessage,
    int? numUnread,
  }) {
    return Match(profile ?? this.profile, lastMessage ?? this.lastMessage, numUnread ?? this.numUnread);
  }
}
