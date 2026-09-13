import 'dart:convert';

import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:common/core/network/unauthorized_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';

import 'category_repository_impl_test.dart' show FakeNetworkConfig;

/// ProductRepositoryImpl keeps its cache write-through: every write edits the
/// cached Product in place rather than marking it stale, because reloading the
/// whole catalogue after one price edit is not worth a round trip. None of that
/// was covered — the file sat at 10% of 229 lines — so these check that a write
/// leaves the cache agreeing with what the server just returned.
class _Recorder {
  final List<String> calls = [];
  final List<String> bodies = [];
  final int status;
  final String body;

  _Recorder({this.status = 200, this.body = '{}'});

  PosService service() {
    return PosService(
      networkConfig: FakeNetworkConfig(),
      client: CustomClient(inner: MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        bodies.add(request.body);
        return http.Response.bytes(utf8.encode(body), status,
            headers: {'content-type': 'application/json; charset=utf-8'});
      })),
    );
  }
}

({ProductRepositoryImpl repo, CachedList<Product> cache, _Recorder recorder})
    _build(_Recorder recorder, {List<Product>? cached}) {
  final cache = CachedList<Product>();
  if (cached != null) cache.fill(cached);
  return (
    repo: ProductRepositoryImpl(cache: cache, posService: recorder.service()),
    cache: cache,
    recorder: recorder,
  );
}

Map<String, dynamic> _unitJson(
        {String id = 'u1', String barcode = '8850001'}) =>
    {
      'id': id,
      'productId': 'p1',
      'unit': 'เม็ด',
      'costPrice': 5,
      'size': 1,
      'barcode': barcode,
      'volume': 0,
      'volumeUnit': '',
    };

Map<String, dynamic> _priceJson({String id = 'pr1', num price = 10}) => {
      'id': id,
      'productId': 'p1',
      'unitId': 'u1',
      'customerType': 'GENERAL',
      'price': price,
    };

Map<String, dynamic> _stockJson({String id = 's1', num quantity = 10}) => {
      'id': id,
      'productId': 'p1',
      'unitId': 'u1',
      'receiveCode': 'RC-1',
      'sequence': 1,
      'lotNumber': 'LOT-1',
      'costPrice': 5,
      'price': 10,
      'import': 10,
      'quantity': quantity,
      'expireDate': '2027-01-01',
      'importDate': '2026-01-01',
    };

Map<String, dynamic> _productJson({
  String name = 'ยาแก้ปวด',
  num quantity = 10,
  num soldFirst = 0,
}) =>
    {
      'id': 'p1',
      'name': name,
      'nameEn': 'Painkiller',
      'description': '',
      'category': 'ยา',
      'status': 'ACTIVE',
      'createdDate': '',
      'price': 10,
      'costPrice': 5,
      'unit': 'เม็ด',
      'quantity': quantity,
      'soldFirst': soldFirst,
      'serialNumber': 'SN-1',
      'minStock': 1,
      'drugRegistrations': [],
      'units': [_unitJson()],
      'prices': [_priceJson()],
      'stocks': [_stockJson()],
    };

/// A cached product built from the same JSON the server would send, so a test
/// can assert the cache changed rather than that it merely differs.
Future<Product> _cachedProduct(
    {String name = 'ยาแก้ปวด', num quantity = 10}) async {
  final recorder = _Recorder(
      body: jsonEncode([_productJson(name: name, quantity: quantity)]));
  final built = _build(recorder);
  final products = await built.repo.getProducts();
  return products.single;
}

void main() {
  group('reads', () {
    test('getProducts fills the cache and returns it', () async {
      final recorder = _Recorder(body: jsonEncode([_productJson()]));
      final built = _build(recorder);

      final products = await built.repo.getProducts();

      expect(products.single.id, 'p1');
      expect(products.single.name, 'ยาแก้ปวด');
      expect(products.single.units.single.barcode, '8850001');
      expect(products.single.prices.single.price, 10);
      expect(products.single.stocks.single.quantity, 10);
      expect(built.cache.needsRefresh, isFalse);
    });

    test('generateSerialNumber unwraps the field', () async {
      final recorder = _Recorder(body: jsonEncode({'serialNumber': 'SN-9'}));

      expect(await _build(recorder).repo.generateSerialNumber(), 'SN-9');
    });

    test('getProductLotsExpired accepts both a bare list and a wrapper',
        () async {
      final bare = _Recorder(body: jsonEncode([_lotJson()]));
      expect(await _build(bare).repo.getProductLotsExpired(), hasLength(1));

      final wrapped = _Recorder(
          body: jsonEncode({
        'data': [_lotJson()]
      }));
      expect(await _build(wrapped).repo.getProductLotsExpired(), hasLength(1));

      final empty = _Recorder(body: jsonEncode({'data': null}));
      expect(await _build(empty).repo.getProductLotsExpired(), isEmpty);
    });

    test('getProductHistoriesByProductId maps the rows', () async {
      final recorder = _Recorder(
          body: jsonEncode([
        {
          'id': 'h1',
          'productId': 'p1',
          'description': 'ขาย',
          'type': 'SALE',
          'unit': 'เม็ด',
          'quantity': 2,
          'balance': 8,
          'import': 0,
          'price': 10,
          'costPrice': 5,
          'createdDate': '',
        }
      ]));

      final rows =
          await _build(recorder).repo.getProductHistoriesByProductId('p1');

      expect(rows.single.balance, 8);
      expect(rows.single.description, 'ขาย');
    });

    test('importProductCSV maps the tally', () async {
      final recorder = _Recorder(
          body: jsonEncode({
        'total': 10,
        'success': 8,
        'failed': 2,
        'errors': ['แถว 3']
      }));

      final result = await _build(recorder)
          .repo
          .importProductCSV(bytes: const [1, 2], filename: 'p.csv');

      expect(result.total, 10);
      expect(result.failed, 2);
      expect(result.errors.single, 'แถว 3');
    });

    test('checkDrugInteractions tolerates a response with no interactions',
        () async {
      final recorder = _Recorder(body: jsonEncode({'other': 1}));

      expect(
          await _build(recorder).repo.checkDrugInteractions(['p1']), isEmpty);
    });
  });

  group('a write keeps the cached product in step', () {
    test('updateProductById rewrites the cached fields', () async {
      final cached = await _cachedProduct(name: 'ชื่อเดิม');
      final recorder =
          _Recorder(body: jsonEncode(_productJson(name: 'ชื่อใหม่')));
      final built = _build(recorder, cached: [cached]);

      await built.repo.updateProductById(
          'p1',
          ProductParam(
            name: 'ชื่อใหม่',
            price: 10,
            costPrice: 5,
            unit: 'เม็ด',
            quantity: 10,
            serialNumber: 'SN-1',
            category: 'ยา',
            status: 'ACTIVE',
            lotNumber: null,
            expireDate: null,
            receiveId: null,
            minStock: 1,
            drugRegistrations: const [],
          ));

      expect(built.cache.items.single.name, 'ชื่อใหม่',
          reason: 'the screen reads the cached product, not the response');
    });

    test('removeProductById drops it from the cache', () async {
      final cached = await _cachedProduct();
      final recorder = _Recorder(body: jsonEncode(_productJson()));
      final built = _build(recorder, cached: [cached]);

      await built.repo.removeProductById('p1');

      expect(built.cache.items, isEmpty);
    });

    test('clearQuantitySoldFirstById updates only soldFirst', () async {
      final cached = await _cachedProduct();
      final recorder =
          _Recorder(body: jsonEncode(_productJson(soldFirst: 4, name: 'อื่น')));
      final built = _build(recorder, cached: [cached]);

      await built.repo.clearQuantitySoldFirstById('p1');

      expect(built.cache.items.single.soldFirst, 4);
      expect(built.cache.items.single.name, 'ยาแก้ปวด',
          reason: 'this write touches one field, not the whole product');
    });

    test('prices are added, edited and removed in the cache', () async {
      final cached = await _cachedProduct();
      var built = _build(_Recorder(body: jsonEncode(_priceJson(id: 'pr2'))),
          cached: [cached]);

      await built.repo.addProductPrice(ProductPriceParam(
          productId: 'p1', unitId: 'u1', customerType: 'WHOLESALE', price: 8));
      expect(cached.prices, hasLength(2));

      built = _build(
          _Recorder(body: jsonEncode(_priceJson(id: 'pr2', price: 7))),
          cached: [cached]);
      await built.repo.updateProductPriceById(
          'pr2',
          ProductPriceParam(
              productId: 'p1',
              unitId: 'u1',
              customerType: 'WHOLESALE',
              price: 7));
      expect(cached.prices.firstWhere((p) => p.id == 'pr2').price, 7);

      built = _build(_Recorder(body: jsonEncode(_priceJson(id: 'pr2'))),
          cached: [cached]);
      await built.repo.removeProductPriceById('pr2');
      expect(cached.prices.map((p) => p.id), ['pr1']);
    });

    test('units are added, edited and removed in the cache', () async {
      final cached = await _cachedProduct();
      var built = _build(
          _Recorder(body: jsonEncode(_unitJson(id: 'u2', barcode: '999'))),
          cached: [cached]);

      await built.repo.addProductUnit(ProductUnitParam(
          productId: 'p1',
          unit: 'แผง',
          costPrice: 50,
          price: 90,
          size: 10,
          barcode: '999',
          volume: 0,
          volumeUnit: ''));
      expect(cached.units, hasLength(2));

      built = _build(
          _Recorder(body: jsonEncode(_unitJson(id: 'u2', barcode: '111'))),
          cached: [cached]);
      await built.repo.updateProductUnitById(
          'u2',
          ProductUnitParam(
              productId: 'p1',
              unit: 'แผง',
              costPrice: 50,
              price: 90,
              size: 10,
              barcode: '111',
              volume: 0,
              volumeUnit: ''));
      expect(cached.units.firstWhere((u) => u.id == 'u2').barcode, '111');

      built = _build(_Recorder(body: jsonEncode(_unitJson(id: 'u2'))),
          cached: [cached]);
      await built.repo.removeProductUnitById('u2');
      expect(cached.units.map((u) => u.id), ['u1']);
    });

    test('stock quantity edits land on the cached lot', () async {
      final cached = await _cachedProduct();
      final built = _build(_Recorder(body: jsonEncode(_stockJson(quantity: 3))),
          cached: [cached]);

      await built.repo.updateProductStockQuantityById(
          's1', UpdateProductStockQuantityParam(quantity: 3));

      expect(cached.stocks.single.quantity, 3,
          reason: 'the sales screen reads the quantity straight off the cache');
    });

    test('getProductStocksByProductId replaces the cached lots', () async {
      final cached = await _cachedProduct();
      final built = _build(
          _Recorder(
              body: jsonEncode(
                  [_stockJson(id: 's2', quantity: 4), _stockJson(id: 's3')])),
          cached: [cached]);

      await built.repo.getProductStocksByProductId('p1');

      expect(cached.stocks.map((s) => s.id), ['s2', 's3']);
    });

    test('updateProductStockSequence replaces the cached lots', () async {
      final cached = await _cachedProduct();
      final built = _build(_Recorder(body: jsonEncode([_stockJson(id: 's9')])),
          cached: [cached]);

      await built.repo.updateProductStockSequence(
          UpdateProductStockSequenceParam(productId: 'p1', stocks: const []));

      expect(cached.stocks.single.id, 's9');
    });

    test('updateProductStock edits the cache without a request', () async {
      final cached = await _cachedProduct();
      final recorder = _Recorder();
      final built = _build(recorder, cached: [cached]);

      final edited = cached.stocks.single;
      await built.repo.updateProductStock(ProductStock(
        id: edited.id,
        unitId: edited.unitId,
        productId: 'p1',
        receiveCode: edited.receiveCode,
        sequence: 2,
        lotNumber: 'LOT-NEW',
        costPrice: 6,
        price: 12,
        import: edited.import,
        quantity: 1,
        expireDate: '2028-01-01',
        importDate: edited.importDate,
      ));

      expect(recorder.calls, isEmpty, reason: 'this one is cache-only');
      expect(cached.stocks.single.quantity, 1);
      expect(cached.stocks.single.lotNumber, 'LOT-NEW');
    });

    test('a write for a product nobody cached is a no-op, not a crash',
        () async {
      final other = await _cachedProduct();
      final built = _build(_Recorder(body: jsonEncode(_priceJson(id: 'pr9'))),
          cached: [other]);

      // The response names product p1; the cache holds a different product.
      other.prices.clear();
      await built.repo.addProductPrice(ProductPriceParam(
          productId: 'nobody',
          unitId: 'u1',
          customerType: 'GENERAL',
          price: 1));

      expect(other.prices, hasLength(1),
          reason: 'the loop matches on the id in the response, which is p1');
    });
  });

  group('failures', () {
    test('a 500 on the catalogue read raises and leaves the cache alone',
        () async {
      final cached = await _cachedProduct();
      final built = _build(_Recorder(status: 500, body: '{"message":"boom"}'),
          cached: [cached]);

      await expectLater(
          built.repo.getProducts(), throwsA(isA<ServerException>()));
      expect(built.cache.items, hasLength(1));
    });

    test('a 404 on a single product raises NotFoundException', () async {
      final built = _build(_Recorder(status: 404, body: '{"message":"no"}'));

      await expectLater(
          built.repo.getProductById('nope'), throwsA(isA<NotFoundException>()));
    });

    test('a 401 on the CSV import still logs the user out', () async {
      // The upload sends a MultipartRequest, which used to go out on its own
      // connection and skip every interceptor — so an expired session showed a
      // generic error here instead of returning to login.
      var loggedOut = 0;
      final client = CustomClient(
          inner:
              MockClient((_) async => http.Response('{"code":"UM-401"}', 401)));
      client.addInterceptor(
          UnauthorizedInterceptor(onUnauthorized: () async => loggedOut++));
      final repo = ProductRepositoryImpl(
        cache: CachedList<Product>(),
        posService:
            PosService(networkConfig: FakeNetworkConfig(), client: client),
      );

      await expectLater(
        repo.importProductCSV(bytes: const [1], filename: 'p.csv'),
        throwsA(isA<AuthException>()),
      );
      expect(loggedOut, 1);
    });
  });
}

Map<String, dynamic> _lotJson() => {
      'id': 'l1',
      'productId': 'p1',
      'lotNumber': 'LOT-1',
      'quantity': 5,
      'costPrice': 5,
      'expireDate': '2027-01-01',
      'notify': false,
    };
