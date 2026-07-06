import 'package:common/config/network_config.dart';
import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/category_repository_impl.dart';

class FakeNetworkConfig implements NetworkConfig {
  @override
  Map<String, String> getHeaders(Uri uri) => {'Content-Type': 'application/json'};

  @override
  bool isDebug() => false;

  @override
  String getHostApp() => 'http://pos.test';

  @override
  String getHostUm() => 'http://um.test';
}

CategoryRepositoryImpl buildRepo(http.Response Function(http.Request) handler) {
  final client = CustomClient(inner: MockClient((request) async => handler(request)));
  final service = PosService(networkConfig: FakeNetworkConfig(), client: client);
  return CategoryRepositoryImpl(posService: service);
}

const categoryBody =
    '{"id":"c1","name":"ยาเม็ด","value":"TABLET","description":"","default":false,"requireCustomerOrder":true}';
const jsonUtf8Headers = {'content-type': 'application/json; charset=utf-8'};

void main() {
  test('getCategories maps the response array', () async {
    final repo = buildRepo((request) => http.Response('[$categoryBody]', 200, headers: jsonUtf8Headers));

    final categories = await repo.getCategories();

    expect(categories, hasLength(1));
    expect(categories.first.name, 'ยาเม็ด');
    expect(categories.first.requireCustomerOrder, isTrue);
  });

  test('getCategoryById throws NotFoundException on 404', () async {
    final repo = buildRepo((request) => http.Response('{"error":"not found"}', 404));

    await expectLater(repo.getCategoryById('missing'), throwsA(isA<NotFoundException>()));
  });

  test('getCategories throws AuthException on 401', () async {
    final repo = buildRepo(
        (request) => http.Response('{"code":"UM-401","message":"session expired"}', 401));

    await expectLater(repo.getCategories(), throwsA(isA<AuthException>()));
  });

  test('getLocalCategories reuses the cached list', () async {
    var networkCalls = 0;
    final repo = buildRepo((request) {
      networkCalls = networkCalls + 1;
      return http.Response('[$categoryBody]', 200, headers: jsonUtf8Headers);
    });

    await repo.getCategories();
    final cached = await repo.getLocalCategories();

    expect(networkCalls, 1);
    expect(cached, hasLength(1));
  });

  test('requireCustomerOrder resolves from the cached category value', () async {
    final repo = buildRepo((request) => http.Response('[$categoryBody]', 200, headers: jsonUtf8Headers));

    expect(await repo.requireCustomerOrder('TABLET'), isTrue);
    expect(await repo.requireCustomerOrder('OTHER'), isFalse);
  });
}
