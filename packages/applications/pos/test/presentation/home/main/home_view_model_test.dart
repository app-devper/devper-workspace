import 'package:flutter_test/flutter_test.dart';
import 'package:pos/presentation/home/main/home_state.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';
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
  Future<System> getSystem() => throw UnimplementedError();

  @override
  String getClientId() => 'C1';
}

void main() {
  test('getRole emits CheckRoleState true for ADMIN', () async {
    final vm = HomeViewModel(loginRepo: FakeLoginRepository(role: 'ADMIN'));

    expectLater(
      vm.states,
      emits(isA<CheckRoleState>().having((s) => s.isAdmin, 'isAdmin', isTrue)),
    );
    vm.getRole();
  });

  test('getRole emits CheckRoleState false for USER', () async {
    final vm = HomeViewModel(loginRepo: FakeLoginRepository(role: 'USER'));

    expectLater(
      vm.states,
      emits(isA<CheckRoleState>().having((s) => s.isAdmin, 'isAdmin', isFalse)),
    );
    vm.getRole();
  });

  test('logout emits LogoutState even when the repository fails', () async {
    final repo = FakeLoginRepository(logoutThrows: true);
    final vm = HomeViewModel(loginRepo: repo);

    expectLater(vm.states, emits(isA<LogoutState>()));
    vm.logout();

    await Future<void>.delayed(Duration.zero);
    expect(repo.logoutCalls, 1);
  });
}
