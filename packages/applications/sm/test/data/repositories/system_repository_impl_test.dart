import 'package:common/config/network_config.dart';
import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sm/data/datasource/network/sm_service.dart';
import 'package:sm/data/repositories/system_repository_impl.dart';

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

SystemRepositoryImpl buildRepo(http.Response Function(http.Request) handler) {
  final client = CustomClient(inner: MockClient((request) async => handler(request)));
  final service = SmService(networkConfig: FakeNetworkConfig(), client: client);
  return SystemRepositoryImpl(service: service);
}

const systemBody =
    '{"id":"s1","clientId":"C1","systemName":"POS","systemCode":"POS","host":"http://pos.test"}';

void main() {
  test('getSystems maps the response array', () async {
    final repo = buildRepo((request) => http.Response('[$systemBody]', 200));

    final systems = await repo.getSystems();

    expect(systems, hasLength(1));
    expect(systems.first.systemCode, 'POS');
    expect(systems.first.host, 'http://pos.test');
  });

  test('getSystemById throws NotFoundException on 404', () async {
    final repo = buildRepo((request) => http.Response('{"message":"not found"}', 404));

    await expectLater(repo.getSystemById('missing'), throwsA(isA<NotFoundException>()));
  });

  test('getSystems throws AuthException on 401', () async {
    final repo = buildRepo(
        (request) => http.Response('{"code":"UM-401","message":"session expired"}', 401));

    await expectLater(repo.getSystems(), throwsA(isA<AuthException>()));
  });
}
