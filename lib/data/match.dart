import 'package:alchemy/data/message.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/data/profile_interaction.dart';

class Match {
  final Profile profile;
  final Message? lastMessage;
  final int numUnread;
  final Set<ProfileInteraction> interactions;

  Match(this.profile, this.lastMessage, this.numUnread, this.interactions);
  Match.fromJson(Map<String, dynamic> values) : this(
    Profile.fromJson(values['profile']),
    values['lastMessage'] == null ? null : Message.fromJson(values['lastMessage']),
    values['numUnread'],
    (values['interactions'] as List<dynamic>).map((e) => ProfileInteraction.fromRelationshipInterest(e)).toSet(),
  );

  Match copyWith({
    Profile? profile,
    Message? lastMessage,
    int? numUnread,
    Set<ProfileInteraction>? interactions,
  }) {
    return Match(profile ?? this.profile, lastMessage ?? this.lastMessage, numUnread ?? this.numUnread, interactions ?? this.interactions);
  }
}
