import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um/domain/entities/auth/passkey.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/platform/passkey_authenticator.dart';
import 'package:um/domain/repositories/login_repository.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

final _system = System(
    id: 's1', clientId: 'C1', systemName: 'POS', systemCode: 'POS', host: 'http://pos.test');

class _Login implements LoginRepository {
  final optionsFor = <String>[];
  final logins = <({String ceremonyId, String credentialJson, String system, String username})>[];

  @override
  Future<PasskeyChallenge> passkeyLoginOptions(String system) async {
    optionsFor.add(system);
    return const PasskeyChallenge(ceremonyId: 'c1', optionsJson: '{"publicKey":{}}');
  }

  @override
  Future<Session> loginWithPasskey({
    required String ceremonyId,
    required String credentialJson,
    required String system,
    String typedUsername = '',
  }) async {
    logins.add((
      ceremonyId: ceremonyId,
      credentialJson: credentialJson,
      system: system,
      username: typedUsername,
    ));
    return Session(
      accessToken: 'tok',
      user: User(
          id: 'u1',
          firstName: 'a',
          lastName: 'b',
          username: 'admin',
          role: 'ADMIN',
          status: 'ACTIVE',
          phone: null,
          email: null,
          createdBy: '',
          createdDate: '',
          updatedBy: '',
          updatedDate: ''),
      system: _system,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Authenticator implements PasskeyAuthenticator {
  final bool cancel;
  final seen = <String>[];
  _Authenticator({this.cancel = false});

  @override
  bool get isSupported => true;

  @override
  Future<String> get(String optionsJson) async {
    seen.add(optionsJson);
    if (cancel) {
      throw const PasskeyException(code: PasskeyException.cancelled, message: 'dismissed');
    }
    return '{"id":"cred"}';
  }
}

void main() {
  test('answers the ceremony UM issued for the system and hands over the typed username', () async {
    final login = _Login();
    final authenticator = _Authenticator();

    final system = await LoginWithPasskeyUseCase(login, authenticator)(
        const PasskeyLoginParam(system: 'POS', typedUsername: 'admin'));

    expect(system.systemCode, 'POS');
    expect(login.optionsFor, ['POS']);
    expect(authenticator.seen, ['{"publicKey":{}}']);
    expect(login.logins.single,
        (ceremonyId: 'c1', credentialJson: '{"id":"cred"}', system: 'POS', username: 'admin'));
  });

  test('a dismissed prompt signs nobody in', () async {
    final login = _Login();

    await expectLater(
      LoginWithPasskeyUseCase(login, _Authenticator(cancel: true))(
          const PasskeyLoginParam(system: 'POS')),
      throwsA(isA<PasskeyException>()),
    );
    expect(login.logins, isEmpty);
  });
}
