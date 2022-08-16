class ScheduledMessage {
  bool ok;
  List<Message> scheduledMessages;

  ScheduledMessage({required this.ok, required this.scheduledMessages});

  factory ScheduledMessage.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['scheduled_messages'] as List;
    List<Message> messages = list.map((i) => Message.fromJson(i)).toList();

    return ScheduledMessage(ok: parsedJson['ok'], scheduledMessages: messages);
  }
}

class Message {
  String id;
  String channelId;
  int postAt;
  int dateCreated;
  String text;

  Message(
      {required this.id,
      required this.channelId,
      required this.postAt,
      required this.dateCreated,
      required this.text});

  factory Message.fromJson(Map<String, dynamic> parsedJson) {
    return Message(
      id: parsedJson['id'],
      channelId: parsedJson['channel_id'],
      postAt: parsedJson['post_at'],
      dateCreated: parsedJson['date_created'],
      text: parsedJson['text'],
    );
  }
}
