enum ProfileInteraction {
  wave('friends'),
  kiss('flings'),
  rose('romance');

  final String relationshipInterest;
  const ProfileInteraction(this.relationshipInterest);

  String getIconFile() => 'assets/interact-icons/$name.png';
  String getSilhouetteFile() => 'assets/interact-icons/$name-silhouette.png';
}
