import '../model/AuthTest.dart';
import '../util/HttpService.dart';

class AuthTestService {
  Future<AuthTest> authTest(String token) async {
    var response =
        await HttpService.create().post('/auth.test', data: {"token": token});
    if (response.statusCode != 200) return AuthTest(ok: false);
    return AuthTest.fromJson(response.data);
  }
}
