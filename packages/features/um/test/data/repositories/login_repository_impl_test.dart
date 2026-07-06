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
}
