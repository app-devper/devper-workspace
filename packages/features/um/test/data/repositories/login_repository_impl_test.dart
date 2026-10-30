import 'dart:convert';

import 'package:common/config/app_config.dart';
import 'package:common/config/network_config.dart';
import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:um/data/datasource/local/token_storage.dart';
import 'package:um/data/datasource/network/um_service.dart';
import 'package:um/data/datasource/session/app_session.dart';
import 'package:um/data/datasource/session/keep_alive_scheduler.dart';
import 'package:um/data/repositories/login_repository_impl.dart';
import 'package:um/domain/entities/auth/param.dart';

class FakeTokenStorage implements TokenStorage {
  String token = '';

  @override
  Future<void> save(String accessToken) async {
    token = accessToken;
  }

  @override
  Future<String> read() async {
    return token;
  }

  @override
  Future<void> clear() async {
    token = '';
  }
}

class FakeNetworkConfig implements NetworkConfig {
  @override
  Map<String, String> getHeaders(Uri uri) => {'Content-Type': 'application/json'};

  @override
  bool isDebug() => false;

  @override
  String getHostApp() => '';

  @override
  String getHostUm() => 'http://um.test';
}

AppSession buildSession() {
  return AppSession(AppConfig(
    apiUrl: 'http://um.test',
    logo: '',
    name: 'test',
    system: 'POS',
    home: '/home',
  ));
}

const validUserBody = '''
{"id":"u1","firstName":"a","lastName":"b","username":"admin","role":"ADMIN","status":"ACTIVE",
"phone":null,"email":null,"createdBy":"x","createdDate":"2026-01-01","updatedBy":"x","updatedDate":"2026-01-01"}
''';

const validSystemBody =
    '{"id":"s1","clientId":"C1","systemName":"POS","systemCode":"POS","host":"http://pos.test"}';

LoginRepositoryImpl buildRepo({
  required FakeTokenStorage tokenStorage,
  required AppSession appSession,
  required KeepAliveScheduler scheduler,
  required http.Response Function(http.Request) handler,
}) {
  final client = CustomClient(inner: MockClient((request) async => handler(request)));
  final service = UmService(networkConfig: FakeNetworkConfig(), client: client);
  return LoginRepositoryImpl(
    service: service,
    tokenStorage: tokenStorage,
    appSession: appSession,
    keepAliveScheduler: scheduler,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTokenStorage tokenStorage;
  late AppSession appSession;
  late KeepAliveScheduler scheduler;

  setUp(() {
    tokenStorage = FakeTokenStorage();
    appSession = buildSession();
    scheduler = KeepAliveScheduler(onTick: () async {}, interval: const Duration(hours: 1));
  });

  tearDown(() {
    scheduler.stop();
  });

  group('loginUser', () {
    test('stores token, loads user and system, starts keep-alive', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) {
          if (request.url.path == '/api/um/v1/auth/login') {
            return http.Response('{"accessToken":"tok.abc"}', 200);
          }
          if (request.url.path == '/api/um/v1/user/info') {
            return http.Response(validUserBody, 200);
          }
          if (request.url.path == '/api/um/v1/auth/system') {
            return http.Response(validSystemBody, 200);
          }
          return http.Response('', 404);
        },
      );

      final session = await repo.loginUser(
          LoginParam(username: 'admin', password: 'secret', system: 'POS'));

      expect(session.accessToken, 'tok.abc');
      expect(session.user.username, 'admin');
      expect(session.system.host, 'http://pos.test');
      expect(tokenStorage.token, 'tok.abc');
      expect(appSession.getAccessToken(), 'tok.abc');
      expect(appSession.getHostApp(), 'http://pos.test');
      expect(appSession.getClientId(), 'C1');
      expect(scheduler.isStarted, isTrue);
    });

    test('wipes stored token when user info fails after login', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) {
          if (request.url.path == '/api/um/v1/auth/login') {
            return http.Response('{"accessToken":"tok.abc"}', 200);
          }
          return http.Response('{"message":"boom"}', 500);
        },
      );

      await expectLater(
        repo.loginUser(LoginParam(username: 'admin', password: 'secret', system: 'POS')),
        throwsA(isA<ServerException>()),
      );
      expect(tokenStorage.token, isEmpty);
      expect(appSession.getAccessToken(), isEmpty);
      expect(scheduler.isStarted, isFalse);
    });

    test('throws AuthException on wrong credentials without storing a token', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) =>
            http.Response('{"code":"UM-401","message":"invalid credentials"}', 401),
      );

      await expectLater(
        repo.loginUser(LoginParam(username: 'admin', password: 'wrong', system: 'POS')),
        throwsA(isA<AuthException>()),
      );
      expect(tokenStorage.token, isEmpty);
    });

    test('throws ValidationException when username is empty', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => fail('must not call the network'),
      );

      await expectLater(
        repo.loginUser(LoginParam(username: '', password: 'secret', system: 'POS')),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('passkey login', () {
    http.Response Function(http.Request) umWith(http.Response Function(http.Request) onLogin) => (request) {
          if (request.url.path == '/api/um/v1/auth/passkey/login/options') {
            expect(jsonDecode(request.body), {'system': 'POS'});
            return http.Response('{"ceremonyId":"c1","options":{"publicKey":{"challenge":"x"}}}', 200);
          }
          if (request.url.path == '/api/um/v1/auth/passkey/login') return onLogin(request);
          if (request.url.path == '/api/um/v1/user/info') return http.Response(validUserBody, 200);
          if (request.url.path == '/api/um/v1/auth/system') return http.Response(validSystemBody, 200);
          return http.Response('', 404);
        };

    test('asks UM for options on the system and hands the request options over as JSON', () async {
      final repo = buildRepo(
          tokenStorage: tokenStorage, appSession: appSession, scheduler: scheduler,
          handler: umWith((_) => fail('not yet')));

      final challenge = await repo.passkeyLoginOptions('POS');

      expect(challenge.ceremonyId, 'c1');
      expect(jsonDecode(challenge.optionsJson), {'publicKey': {'challenge': 'x'}});
    });

    test('sends the answer with the typed username, trimmed, and starts the session', () async {
      Map<String, dynamic>? sent;
      final repo = buildRepo(
          tokenStorage: tokenStorage, appSession: appSession, scheduler: scheduler,
          handler: umWith((request) {
            sent = jsonDecode(request.body);
            return http.Response('{"accessToken":"tok.pk"}', 200);
          }));

      final session = await repo.loginWithPasskey(
          ceremonyId: 'c1', credentialJson: '{"id":"cred"}', system: 'POS', typedUsername: ' admin ');

      expect(sent, {'ceremonyId': 'c1', 'credential': {'id': 'cred'}, 'username': 'admin'});
      expect(session.accessToken, 'tok.pk');
      expect(tokenStorage.token, 'tok.pk');
      expect(scheduler.isStarted, isTrue);
    });

    test('leaves the username out when none was typed', () async {
      Map<String, dynamic>? sent;
      final repo = buildRepo(
          tokenStorage: tokenStorage, appSession: appSession, scheduler: scheduler,
          handler: umWith((request) {
            sent = jsonDecode(request.body);
            return http.Response('{"accessToken":"tok.pk"}', 200);
          }));

      await repo.loginWithPasskey(ceremonyId: 'c1', credentialJson: '{"id":"cred"}', system: 'POS');

      expect(sent, {'ceremonyId': 'c1', 'credential': {'id': 'cred'}});
    });

    test("a passkey of another account is refused in the user's words, without a token", () async {
      final repo = buildRepo(
          tokenStorage: tokenStorage, appSession: appSession, scheduler: scheduler,
          handler: umWith((_) => http.Response(
              '{"code":"UM-401-006","message":"this passkey belongs to a different account"}', 401)));

      await expectLater(
        repo.loginWithPasskey(ceremonyId: 'c1', credentialJson: '{}', system: 'POS', typedUsername: 'bob'),
        throwsA(isA<PasskeyException>()
            .having((e) => e.code, 'code', 'UM-401-006')
            .having((e) => e.message, 'message', contains('บัญชีอื่น'))),
      );
      expect(tokenStorage.token, isEmpty);
      expect(scheduler.isStarted, isFalse);
    });

    test('passkeys switched off at UM read as such', () async {
      final repo = buildRepo(
          tokenStorage: tokenStorage, appSession: appSession, scheduler: scheduler,
          handler: (request) => http.Response('{"code":"UM-404-002","message":"passkeys are not enabled"}', 404));

      await expectLater(repo.passkeyLoginOptions('POS'),
          throwsA(isA<PasskeyException>().having((e) => e.message, 'message', 'ระบบยังไม่เปิดใช้ passkey')));
    });
  });

  group('exchangeTicket', () {
    http.Response Function(http.Request) umWith(String systemBody) => (request) {
          if (request.url.path == '/api/um/v1/auth/exchange') {
            expect(jsonDecode(request.body), {'ticket': 't-1'});
            return http.Response('{"accessToken":"tok.sso"}', 200);
          }
          if (request.url.path == '/api/um/v1/user/info') {
            return http.Response(validUserBody, 200);
          }
          if (request.url.path == '/api/um/v1/auth/system') {
            return http.Response(systemBody, 200);
          }
          return http.Response('', 404);
        };

    test('starts the session from the ticket UM handed over, replacing an older one', () async {
      tokenStorage.token = 'tok.someone-else';
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: umWith(validSystemBody),
      );

      final session = await repo.exchangeTicket('t-1', 'POS');

      expect(session.system.systemCode, 'POS');
      expect(tokenStorage.token, 'tok.sso');
      expect(appSession.getAccessToken(), 'tok.sso');
      expect(scheduler.isStarted, isTrue);
    });

    test('refuses a ticket for another system and keeps no token', () async {
      tokenStorage.token = 'tok.someone-else';
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: umWith(validSystemBody.replaceAll('"systemCode":"POS"', '"systemCode":"GOLD"')),
      );

      await expectLater(repo.exchangeTicket('t-1', 'POS'), throwsA(isA<AuthException>()));
      expect(tokenStorage.token, isEmpty);
      expect(appSession.getAccessToken(), isEmpty);
      expect(scheduler.isStarted, isFalse);
    });

    test('an expired ticket is an AuthException and ends the older session', () async {
      tokenStorage.token = 'tok.someone-else';
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) =>
            http.Response('{"code":"UM-401-002","message":"ticket invalid or expired"}', 401),
      );

      await expectLater(repo.exchangeTicket('old', 'POS'), throwsA(isA<AuthException>()));
      expect(tokenStorage.token, isEmpty);
    });
  });

  group('keepAlive', () {
    test('throws AuthException when no token is stored', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => fail('must not call the network'),
      );

      await expectLater(repo.keepAlive(), throwsA(isA<AuthException>()));
    });

    test('persists the refreshed token', () async {
      tokenStorage.token = 'tok.old';
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => http.Response('{"accessToken":"tok.new"}', 200),
      );

      final login = await repo.keepAlive();

      expect(login.accessToken, 'tok.new');
      expect(tokenStorage.token, 'tok.new');
      expect(appSession.getAccessToken(), 'tok.new');
      expect(scheduler.isStarted, isTrue);
    });
  });

  group('logoutUser', () {
    test('clears local session even when the network call fails', () async {
      tokenStorage.token = 'tok.abc';
      appSession.setAccessToken('tok.abc');
      scheduler.start();
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => throw http.ClientException('offline'),
      );

      final result = await repo.logoutUser();

      expect(result, isTrue);
      expect(tokenStorage.token, isEmpty);
      expect(appSession.getAccessToken(), isEmpty);
      expect(scheduler.isStarted, isFalse);
    });
  });

  group('getRole', () {
    test('reads role from the stored jwt payload', () async {
      final payload = base64Url.encode(utf8.encode('{"role":"ADMIN"}'));
      tokenStorage.token = 'header.$payload.signature';
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => fail('must not call the network'),
      );

      expect(await repo.getRole(), 'ADMIN');
    });

    test('throws AuthException for a malformed token', () async {
      tokenStorage.token = 'not-a-jwt';
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => fail('must not call the network'),
      );

      await expectLater(repo.getRole(), throwsA(isA<AuthException>()));
    });
  });

  group('sessions', () {
    test('getSessions maps the response array', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) {
          expect(request.url.path, '/api/um/v1/auth/sessions');
          expect(request.method, 'GET');
          return http.Response(
            '[{"sessionId":"s1","createdAt":"2026-09-08T00:00:00Z",'
            '"lastActivity":"2026-09-08T01:00:00Z","userAgent":"Chrome",'
            '"ipAddress":"1.2.3.4","system":"SM","current":true}]',
            200,
          );
        },
      );

      final sessions = await repo.getSessions();

      expect(sessions, hasLength(1));
      expect(sessions.first.sessionId, 's1');
      expect(sessions.first.system, 'SM');
      expect(sessions.first.current, isTrue);
    });

    test('getSessions tolerates fields the API omits', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => http.Response('[{"sessionId":"s1"}]', 200),
      );

      final sessions = await repo.getSessions();

      expect(sessions.first.userAgent, '');
      expect(sessions.first.current, isFalse);
    });

    test('revokeSessionById deletes the addressed session', () async {
      late String path;
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) {
          path = request.url.path;
          expect(request.method, 'DELETE');
          return http.Response('{}', 200);
        },
      );

      await expectLater(repo.revokeSessionById('s2'), completion(isTrue));
      expect(path, '/api/um/v1/auth/sessions/s2');
    });

    test('revokeSessionById surfaces a failed delete', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => http.Response('{"message":"nope"}', 404),
      );

      await expectLater(
          repo.revokeSessionById('s2'), throwsA(isA<NotFoundException>()));
    });

    test('revokeOtherSessions returns the revoked count', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) {
          expect(request.url.path, '/api/um/v1/auth/sessions');
          expect(request.method, 'DELETE');
          return http.Response('{"revoked":3}', 200);
        },
      );

      await expectLater(repo.revokeOtherSessions(), completion(3));
    });

    test('revokeOtherSessions defaults to zero when the count is absent', () async {
      final repo = buildRepo(
        tokenStorage: tokenStorage,
        appSession: appSession,
        scheduler: scheduler,
        handler: (request) => http.Response('{}', 200),
      );

      await expectLater(repo.revokeOtherSessions(), completion(0));
    });
  });

}
