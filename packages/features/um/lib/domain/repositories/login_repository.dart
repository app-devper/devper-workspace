import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';

abstract class LoginRepository {
  Future<Session> loginUser(LoginParam param);

  Future<Login> keepAlive();

  Future<bool> logoutUser();

  Future<String> getRole();

  Future<System> getSystem();

  String getClientId();
}
