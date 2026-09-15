import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/repositories/login_repository.dart';

class FakeLoginRepository implements LoginRepository {
  final String role;
  final bool logoutThrows;
  var logoutCalls = 0;

  FakeLoginRepository({this.role = 'USER', this.logoutThrows = false});

  @override
  Future<String> getRole() async => role;

  @override
  Future<bool> logoutUser() async {
    logoutCalls = logoutCalls + 1;
    if (logoutThrows) {
      throw Exception('offline');
    }
    return true;
  }

  @override
  Future<Session> loginUser(LoginParam param) => throw UnimplementedError();

  @override
  Future<Login> keepAlive() => throw UnimplementedError();

  @override
  Future<List<UserSession>> getSessions() => throw UnimplementedError();

  @override
  Future<bool> revokeSessionById(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<int> revokeOtherSessions() => throw UnimplementedError();

  @override
  Future<System> getSystem() => throw UnimplementedError();

  @override
  String getClientId() => 'C1';
}

void main() {
  test('getRole sets isAdmin true for ADMIN', () async {
    final repo = FakeLoginRepository(role: 'ADMIN');
    final vm = HomeViewModel(
      getRoleUseCase: GetRoleUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
    );

    await vm.getRole();

    expect(vm.state.value.isAdmin, isTrue);
  });

  test('getRole sets isAdmin false for USER', () async {
    final repo = FakeLoginRepository(role: 'USER');
    final vm = HomeViewModel(
      getRoleUseCase: GetRoleUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
    );

    await vm.getRole();

    expect(vm.state.value.isAdmin, isFalse);
  });

  test('the menu assumes the smaller role until the answer arrives', () {
    final vm = HomeViewModel(
      getRoleUseCase: GetRoleUseCase(FakeLoginRepository(role: 'ADMIN')),
      logoutUseCase: LogoutUseCase(FakeLoginRepository()),
    );

    expect(vm.state.value.isAdmin, isFalse,
        reason: 'it used to be null, which the view had to special-case');
  });

  test('logout signals once, even when the repository fails', () async {
    final repo = FakeLoginRepository(logoutThrows: true);
    final vm = HomeViewModel(
      getRoleUseCase: GetRoleUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
    );
    var signals = 0;
    vm.loggedOut.listen((_) => signals++);

    await vm.logout();
    await Future<void>.delayed(Duration.zero);

    expect(repo.logoutCalls, 1);
    expect(signals, 1,
        reason: 'the session ends locally whether or not the server agreed');
  });
}
