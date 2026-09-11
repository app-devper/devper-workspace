import 'dart:convert';

import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';

import 'category_repository_impl_test.dart' show FakeNetworkConfig;

String _productJson({String barcode = '8850001'}) => jsonEncode([
      {
        'id': 'p1',
        'name': 'ยาแก้ปวด',
        'quantity': 10,
        'status': 'ACTIVE',
        'category': '',
        'createdDate': '',
        'units': [
          {
            'id': 'u1',
            'productId': 'p1',
            'costPrice': 5,
            'unit': 'เม็ด',
            'size': 1,
            'barcode': barcode,
            'volume': 0,
            'volumeUnit': '',
          }
        ],
      }
    ]);

/// http.Response encodes a String as latin1, which cannot hold Thai. The real
/// service sends UTF-8 bytes, so the fake does too.
http.Response _ok(String body) => http.Response.bytes(utf8.encode(body), 200,
    headers: {'content-type': 'application/json; charset=utf-8'});

ProductRepositoryImpl _buildRepo(http.Response Function(http.Request) handler,
    {List<String>? calls}) {
  final client = CustomClient(inner: MockClient((request) async {
    calls?.add('${request.method} ${request.url.path}');
    return handler(request);
  }));
  return ProductRepositoryImpl(
    posService: PosService(networkConfig: FakeNetworkConfig(), client: client),
  );
}

void main() {
  group('a cold cache is not an answer', () {
    test('getProductByBarcode fetches instead of reporting nothing found',
        () async {
      final calls = <String>[];
      final repo = _buildRepo(
        (_) => _ok(_productJson()),
        calls: calls,
      );

      // Nothing has primed the cache — this is the first thing the till does
      // after a cold start.
      final product = await repo.getProductByBarcode('8850001');

      expect(product, isNotNull,
          reason: 'an empty cache used to read as "no such product"');
      expect(product!.id, 'p1');
      expect(calls, hasLength(1));
    });

    test('a failed inventory load surfaces rather than reading as not-found',
        () async {
      final repo = _buildRepo((_) => http.Response('offline', 503));

      // The important half: the till must be told the shop is offline, not
      // that it does not stock the item in its hand.
      await expectLater(
        repo.getProductByBarcode('8850001'),
        throwsA(isA<AppException>()),
      );
    });

    test('a barcode nobody stocks still answers null', () async {
      final repo = _buildRepo((_) => _ok(_productJson()));

      expect(await repo.getProductByBarcode('0000000'), isNull,
          reason: 'a real miss must stay a miss');
    });

    test('getLocalProductById fetches on a cold cache too', () async {
      final calls = <String>[];
      final repo = _buildRepo(
        (_) => _ok(_productJson()),
        calls: calls,
      );

      expect((await repo.getLocalProductById('p1'))!.id, 'p1');
      expect(calls, hasLength(1));
    });

    test('a warm cache is not refetched', () async {
      final calls = <String>[];
      final repo = _buildRepo(
        (_) => _ok(_productJson()),
        calls: calls,
      );

      await repo.getProducts();
      await repo.getProductByBarcode('8850001');
      await repo.getLocalProductById('p1');
      await repo.getProductByBarcode('0000000');

      expect(calls, hasLength(1),
          reason: 'the fallback must not turn every scan into a round trip');
    });
  });
}
