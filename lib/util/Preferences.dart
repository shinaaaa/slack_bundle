import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        "";
  }

  static Future<bool> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('token', token);
  }

  static Future<String> getChannel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('channel') ?? "";
  }

  static Future<bool> setChannel(String channel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('channel', channel);
  }
}
