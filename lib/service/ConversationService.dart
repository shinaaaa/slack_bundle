import 'package:dio/dio.dart';

import '../model/Conversations.dart';
import '../util/Preferences.dart';

class ConversationService {
  Future<List<Channels>> callConversationsList(String types) async {
    String token = await Preferences.getToken();
    final response =
        await Dio().get('https://slack.com/api/conversations.list?types=$types',
            options: Options(headers: {
              "authorization": "Bearer $token",
            }));
    if (response.statusCode != 200) return [];
    Conversations conversations = Conversations.fromJson(response.data);

    return conversations.channels
        .where((channel) => channel.isMember == true)
        .toList();
  }
}
