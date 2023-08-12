import 'dart:convert';

import 'package:alchemy/data/profile.dart';
import 'package:flutter/services.dart';

import '../dialogue_parser.dart';

class TutorialData {
  final Map<String, String> dialogue;
  final Profile profile;

  TutorialData._(this.dialogue, this.profile);

  static Future<TutorialData> load() {
    final dialogueFuture = rootBundle.loadString('assets/tutorial/dialogue.txt').then((v) => DialogueParser(v).parse());
    final profileFuture = rootBundle.loadString('assets/tutorial/profile.json').then((v) => Profile.fromJson(jsonDecode(v)));
    return Future.wait([dialogueFuture, profileFuture], eagerError: true).then((v) => TutorialData._(v[0] as Map<String, String>, v[1] as Profile));
  }
}
