class Message {
  final int id;
  final int from;
  final String content;
  final DateTime sentAt;

  bool get isLocal => from == 0;

  Message(this.id, this.from, this.content, this.sentAt);
  Message.fromJson(Map<String, dynamic> values) : this(values['id'], values['from'], values['content'], DateTime.parse(values['sentAt']));
}
