import 'package:alchemy/components/profilechip.dart';
import 'package:alchemy/gender_kind.dart';
import 'package:alchemy/strings.dart';
import 'package:flutter/material.dart';

class Profile {
  final String uid;
  final String name;
  final int age;
  final String bio;
  final String gender;
  final List<String> photoUrls;
  final List<String> relationshipInterests;
  final List<String> neurodiversities;
  final List<String> interests;
  final String city;
  final String? pronouns;

  String get genderDisplay {
    switch (gender) {
      case 'man':
        return 'Man';
      case 'nonbinary':
        return 'Non-Binary';
      case 'woman':
        return 'Woman';
      default:
        return gender;
    }
  }

  GenderKind get genderKind {
    switch (gender) {
      case 'man':
        return GenderKind.man;
      case 'woman':
        return GenderKind.woman;
      default:
        return GenderKind.nonbinary;
    }
  }

  Profile(this.uid, this.name, this.age, this.bio, this.gender, this.photoUrls, this.relationshipInterests, this.neurodiversities, this.interests, this.city, this.pronouns);
  Profile.fromJson(Map<String, dynamic> data) : this(
    data['uid'],
    data['name'],
    data['age'],
    data['bio'],
    data['gender'],
    (data['photoUrls'] as List<dynamic>?)?.cast() ?? [],
    (data['relationshipInterests'] as List<dynamic>).cast(),
    (data['neurodiversities'] as List<dynamic>).cast(),
    (data['interests'] as List<dynamic>).cast(),
    data['city'],
    data['pronouns']
  );

  List<Widget> buildChips(Color baseColor, {int? max}) {
    final res = <Widget>[];
    if (pronouns != null) {
      res.add(ProfileChip(pronouns!, baseColor: baseColor));
    }

    res.add(ProfileChip(genderDisplay, baseColor: baseColor));

    for (String s in relationshipInterests) {
      res.add(ProfileChip(capitalizeWords(s), baseColor: baseColor));
    }

    for (String nd in neurodiversities) {
      res.add(ProfileChip(nd, baseColor: baseColor));
    }

    for (String i in interests) {
      res.add(ProfileChip(i, baseColor: baseColor));
    }

    if (max != null && res.length > max) {
      return res.sublist(0, max);
    } else {
      return res;
    }
  }
}
