import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/auth/user_session.dart';

abstract class LoginRepository {
  Future<Session> loginUser(LoginParam param);

  Future<Login> keepAlive();

  Future<bool> logoutUser();

  Future<String> getRole();

  Future<System> getSystem();

  String getClientId();

  Future<List<UserSession>> getSessions();

  Future<bool> revokeSessionById(String sessionId);

  Future<int> revokeOtherSessions();
}
