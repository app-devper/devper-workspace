import 'dart:convert';
import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'package:pos/data/repositories/receive_repository_impl.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'category_repository_impl_test.dart' show FakeNetworkConfig;

// Shape emitted by pos-api entities.Receive: items have no id or lotId.
const receive = {
  'id': 'r1',
  'supplierId': 's1',
  'code': 'RC1',
  'reference': 'invoice',
  'totalCost': 60,
  'createdDate': '2026-09-05T00:00:00Z',
  'status': 'ACTIVE',
  'items': [
    {
      'productId': 'p1',
      'quantity': 3,
      'costPrice': 20,
      'lotNumber': 'L1',
      'expireDate': '2027-01-01T00:00:00Z',
      'unitId': 'u1',
      'baseQuantity': 3
    },
    {
      'productId': 'p1',
      'quantity': 1,
      'costPrice': 25,
      'lotNumber': 'L2',
      'expireDate': '2027-02-01T00:00:00Z'
    },
  ],
};

PosService service(http.Response Function(http.Request) handler) => PosService(
      networkConfig: FakeNetworkConfig(),
      client: CustomClient(inner: MockClient((r) async => handler(r))),
    );

void main() {
  test(
      'receiving reads embedded items and preserves lot metadata on save/delete',
      () async {
    final requests = <http.Request>[];
    final repo = ReceiveRepositoryImpl(posService: service((r) {
      requests.add(r);
      return http.Response(jsonEncode(receive), 200);
    }));
    final items = await repo.getReceiveItemsById('r1');
    expect(requests.single.url.path, '/api/pos/v1/receives/r1');
    expect(items, hasLength(2));
    expect(items.first.receiveId, 'r1');
    expect(items.first.expireDate, '2027-01-01T00:00:00Z');
    // Remove the second row without deleting a stock lot or losing the first row's metadata.
    await repo.updateReceiveById(
        'r1',
        UpdateReceiveParam(
            supplierId: 's1',
            reference: 'invoice',
            totalCost: 60,
            items: [items.first]));
    expect(requests.last.method, 'PUT');
    expect(requests.last.url.path, '/api/pos/v1/receives/r1');
    expect(jsonDecode(requests.last.body)['items'],
        [(receive['items'] as List).first]);
  });

  test('saving an explicitly empty item list can remove the final row',
      () async {
    final repo = ReceiveRepositoryImpl(posService: service((r) {
      expect(jsonDecode(r.body)['items'], isEmpty);
      return http.Response(
          jsonEncode({...receive, 'items': [], 'totalCost': 0}), 200);
    }));
    final saved = await repo.updateReceiveById(
        'r1',
        UpdateReceiveParam(
            supplierId: 's1', reference: 'invoice', totalCost: 0, items: []));
    expect(saved.items, isEmpty);
  });

  test('import uses PATCH and retains the imported status', () async {
    final repo = ReceiveRepositoryImpl(posService: service((r) {
      expect(r.method, 'PATCH');
      expect(r.url.path, '/api/pos/v1/receives/r1/import');
      return http.Response(jsonEncode({...receive, 'status': 'IMPORTED'}), 200);
    }));
    expect((await repo.importReceiveById('r1')).isImported, isTrue);
  });

  test('failed receiving reads propagate instead of becoming empty items',
      () async {
    final repo = ReceiveRepositoryImpl(
        posService:
            service((r) => http.Response('{"error":"session invalid"}', 401)));
    await expectLater(
        repo.getReceiveItemsById('r1'), throwsA(isA<AuthException>()));
  });

  test(
      'expiry quantity edit updates stock and handles stock response without notify',
      () async {
    final repo = ProductRepositoryImpl(posService: service((r) {
      expect(r.method, 'PATCH');
      expect(r.url.path, '/api/pos/v1/products/stocks/stock1/quantity');
      expect(jsonDecode(r.body), {'quantity': 0});
      return http.Response(
          jsonEncode({
            'id': 'stock1',
            'productId': 'p1',
            'quantity': 0,
            'costPrice': 20,
            'lotNumber': 'L1',
            'expireDate': '2027-01-01T00:00:00Z',
          }),
          200);
    }));
    final result = await repo.updateProductLotQuantityByLotId(
        'stock1', UpdateProductLotQuantityParam(quantity: 0));
    expect(result.quantity, 0);
    expect(result.notify, isFalse);
  });
}
