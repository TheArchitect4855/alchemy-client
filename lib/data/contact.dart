class Contact {
  final String id;
  final DateTime dob;
  final bool isRedlisted;
  final bool tosAgreed;

  int get age => (DateTime.now().difference(dob).inDays / 365).floor();

  Contact(this.id, this.dob, this.isRedlisted, this.tosAgreed);
  Contact.fromJson(Map<String, dynamic> data) : this(data['id'], DateTime.parse(data['dob']), data['isRedlisted'], data['tosAgreed']);
}
