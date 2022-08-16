import 'package:dio/dio.dart';

import '../model/Conversations.dart';
import '../util/Preferences.dart';

class ConversationService {
  Future<List<Channels>> callConversationsList() async {
    String token = await Preferences.getToken();
    final response = await Dio().get('https://slack.com/api/conversations.list',
        options: Options(headers: {
          "authorization": "Bearer $token",
        }));
    if (response.statusCode != 200) return [];
    Conversations conversations = Conversations.fromJson(response.data);
    return conversations.channels;
  }
}
