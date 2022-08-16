class AuthTest {
  bool ok;
  String? error;
  String? url;
  String? team;
  String? user;
  String? teamId;
  String? userId;

  AuthTest(
      {required this.ok,
      this.error,
      this.url,
      this.team,
      this.user,
      this.teamId,
      this.userId});

  factory AuthTest.fromJson(Map<String, dynamic> parsedJson) {
    return AuthTest(
      ok: parsedJson['ok'],
      error: parsedJson['error'],
      url: parsedJson['url'],
      team: parsedJson['team'],
      user: parsedJson['user'],
      teamId: parsedJson['team_id'],
      userId: parsedJson['user_id'],
    );
  }
}
