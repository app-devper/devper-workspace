/// An active login session for the current user, as listed by
/// `GET /auth/sessions`. Distinct from [Session], which is the login response.
class UserSession {
  final String sessionId;
  final String createdAt;
  final String lastActivity;
  final String userAgent;
  final String ipAddress;
  final String system;
  final bool current;

  UserSession({
    required this.sessionId,
    required this.createdAt,
    required this.lastActivity,
    required this.userAgent,
    required this.ipAddress,
    required this.system,
    required this.current,
  });
}
