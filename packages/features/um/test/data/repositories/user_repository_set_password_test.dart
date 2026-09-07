import 'dart:convert';

import 'package:common/config/network_config.dart';
import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:um/data/datasource/network/um_service.dart';
import 'package:um/data/repositories/user_repository_impl.dart';
import 'package:um/domain/entities/user/param.dart';

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

UserRepositoryImpl buildRepo(http.Response Function(http.Request) handler) {
  final client = CustomClient(inner: MockClient((request) async => handler(request)));
  return UserRepositoryImpl(
    service: UmService(networkConfig: FakeNetworkConfig(), client: client),
  );
}

void main() {
  test('setPasswordById patches the addressed user', () async {
    late http.Request captured;
    final repo = buildRepo((request) {
      captured = request;
      return http.Response('{}', 200);
    });

    await expectLater(
      repo.setPasswordById(SetPasswordParam(userId: 'u1', password: 'secret1')),
      completion(isTrue),
    );

    expect(captured.method, 'PATCH');
    expect(captured.url.path, '/api/um/v1/user/u1/set-password');
    expect(jsonDecode(captured.body), {'password': 'secret1'});
  });

  test('setPasswordById rejects an empty password before calling the API', () async {
    var called = false;
    final repo = buildRepo((request) {
      called = true;
      return http.Response('{}', 200);
    });

    await expectLater(
      repo.setPasswordById(SetPasswordParam(userId: 'u1', password: '')),
      throwsA(isA<ValidationException>()),
    );
    expect(called, isFalse);
  });

  test('setPasswordById surfaces an API failure', () async {
    final repo = buildRepo((request) => http.Response('{"message":"denied"}', 403));

    await expectLater(
      repo.setPasswordById(SetPasswordParam(userId: 'u1', password: 'secret1')),
      throwsA(isA<ForbiddenException>()),
    );
  });
}
