enum ProfileInteraction {
  wave('friends'),
  kiss('flings'),
  rose('romance');

  final String relationshipInterest;
  const ProfileInteraction(this.relationshipInterest);

  String getIconFile() => 'assets/interact-icons/$name.png';
  String getSilhouetteFile() => 'assets/interact-icons/$name-silhouette.png';

  static ProfileInteraction fromRelationshipInterest(String s) {
    for (final n in ProfileInteraction.values) {
      if (n.relationshipInterest == s) return n;
    }

    throw FormatException('$s is not a valid relationship interest');
  }
}
