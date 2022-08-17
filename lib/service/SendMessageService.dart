import 'package:dio/dio.dart';

import '../model/PostMessage.dart';
import '../model/ScheduledMessage.dart';
import '../util/Preferences.dart';

class SendMessageService {
  Future<bool> callPostMessage(String channel, String text) async {
    String token = await Preferences.getToken();

    final response = await Dio().post('https://slack.com/api/chat.postMessage',
        data: {"channel": channel, "text": text},
        options: Options(headers: {"authorization": "Bearer $token"}));

    if (response.statusCode != 200) return false;
    PostMessage result = PostMessage.fromJson(response.data);
    return result.ok;
  }

  Future callFileUpload(String channel, String text, String filePath) async {
    var formData = FormData.fromMap({
      "channels": channel,
      'file': await MultipartFile.fromFile(filePath),
      "initial_comment": text
    });

    String token = await Preferences.getToken();

    final response = await Dio().post('https://slack.com/api/files.upload',
        data: formData,
        options: Options(headers: {"authorization": "Bearer $token"}));

    if (response.statusCode != 200) return false;
    Slack result = Slack.fromJson(response.data);
    return result.ok;
  }

  Future<bool> callScheduleMessage(
      String channel, String time, String text) async {
    String token = await Preferences.getToken();
    final response = await Dio().post(
        'https://slack.com/api/chat.scheduleMessage',
        data: {"channel": channel, "post_at": time, "text": text},
        options: Options(headers: {"authorization": "Bearer $token"}));
    if (response.statusCode != 200) return false;
    Slack result = Slack.fromJson(response.data);
    return result.ok;
  }

  Future<ScheduledMessage?> callScheduledMessagesList(String channel) async {
    String token = await Preferences.getToken();

    final response = await Dio().post(
        'https://slack.com/api/chat.scheduledMessages.list',
        data: {"channel": channel},
        options: Options(headers: {"authorization": "Bearer $token"}));
    if (response.statusCode != 200) return null;
    ScheduledMessage result = ScheduledMessage.fromJson(response.data);
    return result;
  }

  Future<bool> callDeleteScheduledMessagesList(
      String channel, String messageId) async {
    String token = await Preferences.getToken();

    final response = await Dio().post(
        'https://slack.com/api/chat.deleteScheduledMessage',
        data: {"channel": channel, "scheduled_message_id": messageId},
        options: Options(headers: {"authorization": "Bearer $token"}));

    if (response.statusCode != 200) return false;
    Slack result = Slack.fromJson(response.data);
    return result.ok;
  }

// void callFilesUpload() async {
//   // file picker를 통해 파일 여러개 선택
//   FilePickerResult? result =
//   await FilePicker.platform.pickFiles(allowMultiple: true);
//
//   if (result != null) {
//     final filePaths = result.paths;
//
//     // 파일 경로를 통해 formData 생성
//     var dio = Dio();
//     var formData = FormData.fromMap({
//       'files': List.generate(filePaths,
//               (index) => MultipartFile.fromFileSync(filePaths[index]!))
//     });
//
//     // 업로드 요청
//     final response = await dio.post('/upload', data: formData);
//   } else {
//     // 아무런 파일도 선택되지 않음.
//   }
}

class Slack {
  final bool ok;

  Slack(this.ok);

  Slack.fromJson(Map<String, dynamic> json) : ok = json['ok'];

  Map<String, dynamic> toJson() => {"ok": ok};
}
