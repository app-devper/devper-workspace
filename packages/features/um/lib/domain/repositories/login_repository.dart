import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/passkey.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/auth/user_session.dart';

abstract class LoginRepository {
  Future<Session> loginUser(LoginParam param);

  /// Starts a session from the one-time ticket UM put in the address when the
  /// user opened this app from UM (um-api ADR-0011); refuses another [system].
  Future<Session> exchangeTicket(String ticket, String system);

  /// Starts a passkey login on [system] (um-api ADR-0010).
  Future<PasskeyChallenge> passkeyLoginOptions(String system);

  /// Finishes it with the authenticator's answer. A non-blank [typedUsername]
  /// must own the passkey, or UM refuses with `UM-401-006`.
  Future<Session> loginWithPasskey({
    required String ceremonyId,
    required String credentialJson,
    required String system,
    String typedUsername = '',
  });

  Future<Login> keepAlive();

  Future<bool> logoutUser();

  Future<String> getRole();

  Future<System> getSystem();

  String getClientId();

  Future<List<UserSession>> getSessions();

  Future<bool> revokeSessionById(String sessionId);

  Future<int> revokeOtherSessions();
}
