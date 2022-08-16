import 'package:dio/dio.dart';
import 'package:slack_bundle/model/AuthTest.dart';

class AuthTestService {
  Future<AuthTest> authTest(String token) async {
    var response = await Dio().post('https://slack.com/api/auth.test',
        options: Options(headers: {"authorization": "Bearer $token"}));

    if (response.statusCode != 200) return AuthTest(ok: false);
    return AuthTest.fromJson(response.data);
  }
}
