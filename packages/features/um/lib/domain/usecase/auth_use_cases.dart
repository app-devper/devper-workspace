import 'package:um/domain/repositories/login_repository.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/role.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/auth/user_session.dart';

class LoginUseCase {
  final LoginRepository repository;
  const LoginUseCase(this.repository);
  Future<System> call(LoginParam param) async =>
      (await repository.loginUser(param)).system;
}

class RestoreSessionUseCase {
  final LoginRepository repository;
  const RestoreSessionUseCase(this.repository);
  Future<System> call() async {
    await repository.keepAlive();
    return await repository.getSystem();
  }
}

class LogoutUseCase {
  final LoginRepository repository;
  const LogoutUseCase(this.repository);
  Future<bool> call() => repository.logoutUser();
}

class GetRoleUseCase {
  final LoginRepository repository;
  const GetRoleUseCase(this.repository);
  /// The signed-in user's role, or null when the token names none.
  Future<Role?> call() async => Role.parse(await repository.getRole());

  /// Whether the signed-in user is at least [min]. A role that cannot be read
  /// grants nothing: every screen that asks gets the same answer.
  Future<bool> atLeast(Role min) async {
    try {
      return (await call())?.atLeast(min) ?? false;
    } on Exception {
      return false;
    }
  }
}

class GetSessionsUseCase {
  final LoginRepository repository;
  const GetSessionsUseCase(this.repository);
  Future<List<UserSession>> call() => repository.getSessions();
}

class RevokeSessionUseCase {
  final LoginRepository repository;
  const RevokeSessionUseCase(this.repository);
  Future<bool> call(String param) => repository.revokeSessionById(param);
}

class RevokeOtherSessionsUseCase {
  final LoginRepository repository;
  const RevokeOtherSessionsUseCase(this.repository);
  Future<int> call() => repository.revokeOtherSessions();
}

class GetClientIdUseCase {
  final LoginRepository repository;
  const GetClientIdUseCase(this.repository);
  String call() => repository.getClientId();
}
