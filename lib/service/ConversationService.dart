import '../model/Conversations.dart';
import '../util/HttpService.dart';
import '../util/Preferences.dart';

class ConversationService {
  Future<List<Channels>> callConversationsList(String types) async {
    String token = await Preferences.getToken();
    final response = await HttpService.create()
        .post('/conversations.list?types=$types', data: {'token': token});

    if (response.statusCode != 200) return [];
    Conversations conversations = Conversations.fromJson(response.data);
    if (conversations.error.isNotEmpty) return [];
    if (conversations.channels.isEmpty) return [];
    return conversations.channels
        .where((channel) => channel.isMember == true)
        .toList();
  }
}
