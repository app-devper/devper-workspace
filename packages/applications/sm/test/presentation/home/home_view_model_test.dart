import 'package:flutter_test/flutter_test.dart';
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';
import 'package:sm/domain/usecase/system/create_system_use_case.dart';
import 'package:sm/domain/usecase/system/get_systems_use_case.dart';
import 'package:sm/domain/usecase/system/remove_system_by_id_use_case.dart';
import 'package:sm/domain/usecase/system/update_system_by_id_use_case.dart';
import 'package:sm/presentation/home/main/home_view_model.dart';
import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart' as um;
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/repositories/login_repository.dart';

System _system(String id, String code) => System(
      id: id,
      clientId: 'C1',
      systemName: code,
      systemCode: code,
      host: 'http://$code.test',
    );

class FakeSystemRepository implements SystemRepository {
  FakeSystemRepository({this.failWith});

  final Exception? failWith;
  final List<String> calls = [];
  List<System> stored = [_system('s1', 'POS')];

  @override
  Future<List<System>> getSystems() async {
    calls.add('getSystems');
    if (failWith != null) throw failWith!;
    return stored;
  }

  @override
  Future<System> createSystem(CreateParam param) async {
    calls.add('createSystem:${param.systemCode}');
    if (failWith != null) throw failWith!;
    stored = [...stored, _system('s2', param.systemCode)];
    return stored.last;
  }

  @override
  Future<System> getSystemById(String systemId) async => _system(systemId, 'POS');

  @override
  Future<System> updateSystemById(UpdateSystemParam param) async {
    calls.add('updateSystemById:${param.systemId}');
    if (failWith != null) throw failWith!;
    return _system(param.systemId, param.systemName);
  }

  @override
  Future<System> removeSystemById(String systemId) async {
    calls.add('removeSystemById:$systemId');
    if (failWith != null) throw failWith!;
    stored = stored.where((item) => item.id != systemId).toList();
    return _system(systemId, 'POS');
  }
}

class FakeLoginRepository implements LoginRepository {
  FakeLoginRepository({this.logoutFails = false, this.role = 'SUPER'});

  final bool logoutFails;
  final String role;
  bool loggedOut = false;

  @override
  Future<bool> logoutUser() async {
    if (logoutFails) throw Exception('network down');
    loggedOut = true;
    return true;
  }

  @override
  Future<Session> loginUser(LoginParam param) => throw UnimplementedError();

  @override
  Future<Login> keepAlive() => throw UnimplementedError();

  @override
  Future<String> getRole() async => role;

  @override
  Future<List<UserSession>> getSessions() => throw UnimplementedError();

  @override
  Future<bool> revokeSessionById(String sessionId) => throw UnimplementedError();

  @override
  Future<int> revokeOtherSessions() => throw UnimplementedError();

  @override
  Future<um.System> getSystem() => throw UnimplementedError();

  @override
  String getClientId() => 'C1';
}

HomeViewModel buildViewModel(FakeSystemRepository repo, FakeLoginRepository login) {
  return HomeViewModel(
    getSystemsUseCase: GetSystemsUseCase(systemRepo: repo),
    createSystemUseCase: CreateSystemUseCase(systemRepo: repo),
    updateSystemByIdUseCase: UpdateSystemByIdUseCase(systemRepo: repo),
    removeSystemByIdUseCase: RemoveSystemByIdUseCase(systemRepo: repo),
    loginRepo: login,
  );
}

void main() {
  test('getSystems fills items and clears loading', () async {
    final repo = FakeSystemRepository();
    final viewModel = buildViewModel(repo, FakeLoginRepository());

    await viewModel.getSystems();

    expect(viewModel.state.value.items, hasLength(1));
    expect(viewModel.state.value.loading, isFalse);
    expect(viewModel.state.value.error, isNull);
  });

  test('createSystem reloads the list so the new system shows up', () async {
    final repo = FakeSystemRepository();
    final viewModel = buildViewModel(repo, FakeLoginRepository());

    await viewModel.createSystem(CreateParam(
      clientId: 'C1',
      systemName: 'SM',
      systemCode: 'SM',
      host: 'http://sm.test',
    ));

    expect(repo.calls, ['createSystem:SM', 'getSystems']);
    expect(viewModel.state.value.items, hasLength(2));
  });

  test('updateSystemById reloads the list', () async {
    final repo = FakeSystemRepository();
    final viewModel = buildViewModel(repo, FakeLoginRepository());

    await viewModel.updateSystemById(UpdateSystemParam(
      systemId: 's1',
      systemName: 'POS 2',
      host: 'http://pos2.test',
    ));

    expect(repo.calls, ['updateSystemById:s1', 'getSystems']);
  });

  test('removeSystemById drops the system from the list', () async {
    final repo = FakeSystemRepository();
    final viewModel = buildViewModel(repo, FakeLoginRepository());

    await viewModel.removeSystemById('s1');

    expect(repo.calls, ['removeSystemById:s1', 'getSystems']);
    expect(viewModel.state.value.items, isEmpty);
  });

  test('a failing call surfaces an error that consumeError clears', () async {
    final repo = FakeSystemRepository(failWith: Exception('boom'));
    final viewModel = buildViewModel(repo, FakeLoginRepository());

    await viewModel.getSystems();

    expect(viewModel.state.value.loading, isFalse);
    expect(viewModel.state.value.error, isNotNull);

    viewModel.consumeError();
    expect(viewModel.state.value.error, isNull);
  });

  test('SUPER can manage both systems and users', () async {
    final viewModel =
        buildViewModel(FakeSystemRepository(), FakeLoginRepository(role: 'SUPER'));

    await viewModel.loadRole();

    expect(viewModel.state.value.canManageSystems, isTrue);
    expect(viewModel.state.value.canManageUsers, isTrue);
  });

  test('ADMIN can manage users but not systems', () async {
    final viewModel =
        buildViewModel(FakeSystemRepository(), FakeLoginRepository(role: 'ADMIN'));

    await viewModel.loadRole();

    expect(viewModel.state.value.canManageSystems, isFalse);
    expect(viewModel.state.value.canManageUsers, isTrue);
  });

  test('USER can manage neither', () async {
    final viewModel =
        buildViewModel(FakeSystemRepository(), FakeLoginRepository(role: 'USER'));

    await viewModel.loadRole();

    expect(viewModel.state.value.canManageSystems, isFalse);
    expect(viewModel.state.value.canManageUsers, isFalse);
  });

  test('logout marks the session as logged out', () async {
    final login = FakeLoginRepository();
    final viewModel = buildViewModel(FakeSystemRepository(), login);

    await viewModel.logout();

    expect(login.loggedOut, isTrue);
    expect(viewModel.state.value.loggedOut, isTrue);
  });

  test('logout still logs out locally when the server call fails', () async {
    final login = FakeLoginRepository(logoutFails: true);
    final viewModel = buildViewModel(FakeSystemRepository(), login);

    await viewModel.logout();

    expect(login.loggedOut, isFalse);
    expect(viewModel.state.value.loggedOut, isTrue);
  });
}
