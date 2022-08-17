class PostMessage {
  bool ok;
  String? error;
  String? channel;
  String? ts;
  Message? message;

  PostMessage({
    required this.ok,
    this.error,
    this.channel,
    this.ts,
    this.message,
  });

  factory PostMessage.fromJson(Map<String, dynamic> parsedJson) {
    var parsedMessage = parsedJson['message'] == null
        ? null
        : Message.fromJson(parsedJson['message']);
    return PostMessage(
      ok: parsedJson['ok'],
      error: parsedJson['error'],
      channel: parsedJson['channel'],
      ts: parsedJson['ts'],
      message: parsedMessage,
    );
  }
}

class Message {
  String text;
  String user;
  String botId;
  String type;
  String ts;

  Message({
    required this.text,
    required this.user,
    required this.botId,
    required this.type,
    required this.ts,
  });

  factory Message.fromJson(Map<String, dynamic> parsedJson) {
    return Message(
      text: parsedJson['text'],
      user: parsedJson['user'],
      botId: parsedJson['bot_id'],
      type: parsedJson['type'],
      ts: parsedJson['ts'],
    );
  }
}
