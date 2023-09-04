class Contact {
  final String id;
  final String phone;
  final DateTime dob;
  final bool isRedlisted;
  final bool tosAgreed;

  int get age => (DateTime.now().difference(dob).inDays / 365).floor();

  Contact(this.id, this.phone, this.dob, this.isRedlisted, this.tosAgreed);
  Contact.fromJson(Map<String, dynamic> data)
      : this(data['id'], data['phone'], DateTime.parse(data['dob']),
            data['isRedlisted'], data['tosAgreed']);
}
