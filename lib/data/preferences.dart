class Preferences {
  final bool allowNotifications;
  final bool showTransgender;
  final Set<String> genderInterests;

  Preferences(this.allowNotifications, this.showTransgender, this.genderInterests);
  Preferences.fromJson(Map<String, dynamic> values) : this(
    values['allowNotifications'],
    values['showTransgender'],
    (values['genderInterests'] as List<dynamic>).cast<String>().toSet(),
  );

  Preferences copyWith({
    bool? allowNotifications,
    bool? showTransgender,
    Set<String>? genderInterests,
  }) => Preferences(allowNotifications ?? this.allowNotifications, showTransgender ?? this.showTransgender, genderInterests ?? this.genderInterests);

  Map<String, dynamic> toJson() => {
    'allowNotifications': allowNotifications,
    'showTransgender': showTransgender,
    'genderInterests': genderInterests.toList(),
  };
}
