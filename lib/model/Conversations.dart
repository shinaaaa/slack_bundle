class Conversations {
  bool ok;
  List<Channels> channels;

  Conversations({required this.ok, required this.channels});

  factory Conversations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['channels'] as List;
    List<Channels> channels = list.map((i) => Channels.fromJson(i)).toList();

    return Conversations(ok: parsedJson['ok'], channels: channels);
  }
}

class Channels {
  String id;
  String name;
  bool isChannel;
  bool isGroup;
  bool isIm;
  bool isArchived;
  bool isGeneral;
  bool isMember;
  bool isPrivate;
  bool isMpim;

  Channels(
      {required this.id,
      required this.name,
      required this.isChannel,
      required this.isGroup,
      required this.isIm,
      required this.isArchived,
      required this.isGeneral,
      required this.isMember,
      required this.isPrivate,
      required this.isMpim});

  factory Channels.fromJson(Map<String, dynamic> parsedJson) {
    return Channels(
      id: parsedJson['id'],
      name: parsedJson['name'],
      isChannel: parsedJson['is_channel'],
      isGroup: parsedJson['is_group'],
      isIm: parsedJson['is_im'],
      isArchived: parsedJson['is_archived'],
      isGeneral: parsedJson['is_general'],
      isMember: parsedJson['is_member'],
      isPrivate: parsedJson['is_private'],
      isMpim: parsedJson['is_mpim'],
    );
  }
}
