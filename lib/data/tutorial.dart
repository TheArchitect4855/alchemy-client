import 'dart:convert';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/services/explore.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/services.dart';
import '../dialogue_parser.dart';

class TutorialData {
  final Map<String, String> dialogue;
  final Profile profile;

  TutorialData._(this.dialogue, this.profile);

  static Future<TutorialData> load() {
    final dialogueFuture = rootBundle.loadString('assets/tutorial/dialogue.txt').then((v) => DialogueParser(v).parse());
    final tutorialProfileFuture = rootBundle.loadString('assets/tutorial/profile.json').then((v) => Profile.fromJson(jsonDecode(v)));
    final potentialMatches = ExploreService.instance.getPotentialMatchesAsync(LocationService.instance, RequestsService.instance);
    Future<Profile> profileFuture = potentialMatches.then((v) {
      if (v.isEmpty) {
        return tutorialProfileFuture;
      } else {
        var profile = v[0];
        profile = profile.copyWith(profile.pronouns, relationshipInterests: [ 'friends', 'flings', 'romance' ]);
        return profile;
      }
    });

    return Future.wait([dialogueFuture, profileFuture], eagerError: true)
      .then((v) => TutorialData._(v[0] as Map<String, String>, v[1] as Profile));
  }
}
