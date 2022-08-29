import 'package:dio/dio.dart';

import '../model/PostMessage.dart';
import '../model/ScheduledMessage.dart';
import '../util/HttpService.dart';
import '../util/Preferences.dart';

class SendMessageService {
  Future<bool> callPostMessage(String channel, String text) async {
    String token = await Preferences.getToken();

    final response = await HttpService.create().post('/chat.postMessage',
        data: {"token": token, "channel": channel, "text": text});

    if (response.statusCode != 200) return false;
    PostMessage result = PostMessage.fromJson(response.data);
    return result.ok;
  }

  Future callFileUpload(
      String channel, String text, Stream<List<int>> fileStream) async {
    String token = await Preferences.getToken();
    var formData = FormData.fromMap({
      "token": token,
      "channels": channel,
      'file': fileStream,
      "initial_comment": text
    });

    final response =
        await HttpService.create().post('/files.upload', data: formData);

    if (response.statusCode != 200) return false;
    Slack result = Slack.fromJson(response.data);
    return result.ok;
  }

  Future<bool> callScheduleMessage(
      String channel, String time, String text) async {
    String token = await Preferences.getToken();
    final response = await HttpService.create().post('/chat.scheduleMessage',
        data: {
          "token": token,
          "channel": channel,
          "post_at": time,
          "text": text
        });
    if (response.statusCode != 200) return false;
    Slack result = Slack.fromJson(response.data);
    return result.ok;
  }

  Future<ScheduledMessage?> callScheduledMessagesList(String channel) async {
    String token = await Preferences.getToken();

    final response = await HttpService.create().post(
        '/chat.scheduledMessages.list',
        data: {"token": token, "channel": channel});
    if (response.statusCode != 200) return null;
    ScheduledMessage result = ScheduledMessage.fromJson(response.data);
    return result;
  }

  Future<bool> callDeleteScheduledMessagesList(
      String channel, String messageId) async {
    String token = await Preferences.getToken();

    final response = await HttpService.create()
        .post('/chat.deleteScheduledMessage', data: {
      "token": token,
      "channel": channel,
      "scheduled_message_id": messageId
    });

    if (response.statusCode != 200) return false;
    Slack result = Slack.fromJson(response.data);
    return result.ok;
  }
}

class Slack {
  final bool ok;

  Slack(this.ok);

  Slack.fromJson(Map<String, dynamic> json) : ok = json['ok'];

  Map<String, dynamic> toJson() => {"ok": ok};
}
