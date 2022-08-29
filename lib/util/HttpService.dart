import 'package:dio/dio.dart';

class HttpService {
  static Dio create() {
    var options = BaseOptions(
      baseUrl: 'https://slack.com/api',
      contentType: Headers.formUrlEncodedContentType,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    return Dio(options);
  }
}
