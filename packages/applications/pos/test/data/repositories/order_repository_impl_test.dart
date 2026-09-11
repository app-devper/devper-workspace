import 'dart:convert';

import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/order_repository_impl.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';

import 'category_repository_impl_test.dart' show FakeNetworkConfig;

/// The order path had no tests at all: order_repository_impl and order_mapper
/// were both at 0% line coverage while every one of their JSON reads was
/// rewritten to go through extension methods. An extension reached through a
/// dynamic receiver compiles and then throws NoSuchMethodError, so these
/// exercise each read end to end rather than trusting the casts by eye.
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
        calls.add(
            '${request.method} ${request.url.path}${request.url.hasQuery ? '?${request.url.query}' : ''}');
        bodies.add(request.body);
        return http.Response.bytes(utf8.encode(body), status,
            headers: {'content-type': 'application/json; charset=utf-8'});
      })),
    );
  }
}

OrderRepositoryImpl _repo(_Recorder recorder) =>
    OrderRepositoryImpl(posService: recorder.service());

const _orderJson = {
  'id': 'o1',
  'code': 'OR-1',
  'customerCode': 'C1',
  'customerName': 'ลูกค้าทั่วไป',
  'createdDate': '2026-09-11T10:00:00.000Z',
  'total': 120,
  'totalCost': 60,
  'discount': 5,
  'type': 'Cash',
};

Map<String, dynamic> _itemJson({Map<String, dynamic>? product}) => {
      'id': 'i1',
      'quantity': 2,
      'price': 60,
      'costPrice': 30,
      'discount': 5,
      'createdDate': '2026-09-11T10:00:00.000Z',
      'oversoldQty': 1,
      'returnedQty': 0,
      if (product != null) 'product': product,
    };

const _productJson = {
  'id': 'p1',
  'name': 'ยาแก้ปวด',
  'status': 'ACTIVE',
  'category': 'ยา',
  'createdDate': '',
  'units': [],
  'prices': [],
  'stocks': [],
};

ProductUnit _unit() => ProductUnit(
      id: 'unit-1',
      productId: 'p1',
      costPrice: 5,
      unit: 'เม็ด',
      size: 1,
      barcode: '8850001',
      volume: 0,
      volumeUnit: '',
    );

ProductStock _stock(String id, int quantity) => ProductStock(
      id: id,
      unitId: 'unit-1',
      productId: 'p1',
      receiveCode: '',
      sequence: 1,
      lotNumber: 'LOT-$id',
      costPrice: 5,
      price: 10,
      import: quantity,
      quantity: quantity,
      expireDate: '',
      importDate: '',
    );

OrderItem _orderItem({int quantity = 1, List<ProductStock>? stocks}) {
  final item = OrderItem(
    product: ProductUnitItem(
      id: 'p1',
      name: 'ยาแก้ปวด',
      category: 'ยา',
      status: productStatusActive,
      createdDate: '',
      unit: _unit(),
      prices: const [],
      stocks: stocks ?? [_stock('stock-1', 10)],
    ),
    quantity: quantity,
    customerType: priceTypeStock,
  );
  return item;
}

void main() {
  group('reads', () {
    test('createOrder returns the order and the stocks it moved', () async {
      final recorder = _Recorder(
        body: jsonEncode({
          'data': _orderJson,
          'stocks': [
            {
              'id': 'stock-1',
              'unitId': 'unit-1',
              'productId': 'p1',
              'receiveCode': '',
              'sequence': 1,
              'lotNumber': 'LOT-1',
              'costPrice': 5,
              'price': 10,
              'import': 10,
              'quantity': 8,
              'expireDate': '',
              'importDate': '',
            }
          ],
        }),
      );

      final result = await _repo(recorder).createOrder(CreateOrderParam(
        customerCode: 'C1',
        customerName: 'ลูกค้าทั่วไป',
        amount: 120,
        items: [_orderItem()],
        type: 'Cash',
      ));

      expect(result.data.id, 'o1');
      expect(result.data.total, 120);
      expect(result.data.customerName, 'ลูกค้าทั่วไป');
      expect(result.stocks, hasLength(1));
      expect(result.stocks.single.quantity, 8);
    });

    test('createOrder tolerates a response with no stocks', () async {
      final recorder = _Recorder(body: jsonEncode({'data': _orderJson}));

      final result = await _repo(recorder).createOrder(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 0,
        items: [_orderItem()],
        type: 'Cash',
      ));

      expect(result.stocks, isEmpty);
    });

    test('getOrderRange maps the summaries and passes the dates through',
        () async {
      final recorder = _Recorder(body: jsonEncode([_orderJson]));

      final summaries = await _repo(recorder).getOrderRange(
          GetOrderRangeParam(startDate: '2026-09-01', endDate: '2026-09-30'));

      expect(summaries, hasLength(1));
      expect(summaries.single.id, 'o1');
      expect(summaries.single.totalCost, 60);
      expect(recorder.calls.single,
          'GET /api/pos/v1/orders?startDate=2026-09-01&endDate=2026-09-30');
    });

    test('getOrderById maps the detail and its items', () async {
      final recorder = _Recorder(
        body: jsonEncode({
          ..._orderJson,
          'items': [_itemJson(product: _productJson)],
        }),
      );

      final detail = await _repo(recorder).getOrderById('o1');

      expect(detail.id, 'o1');
      expect(detail.items, hasLength(1));
      expect(detail.items.single.quantity, 2);
      expect(detail.items.single.oversoldQty, 1);
      expect(detail.items.single.product?.name, 'ยาแก้ปวด');
    });

    test('removeOrderById maps the deleted detail', () async {
      final recorder =
          _Recorder(body: jsonEncode({..._orderJson, 'items': []}));

      final detail = await _repo(recorder).removeOrderById('o1');

      expect(detail.id, 'o1');
      expect(detail.items, isEmpty);
      expect(recorder.calls.single, 'DELETE /api/pos/v1/orders/o1');
    });

    test('getOrderItemByProductId maps a list of items', () async {
      final recorder = _Recorder(body: jsonEncode([_itemJson()]));

      final items = await _repo(recorder).getOrderItemByProductId('p1');

      expect(items, hasLength(1));
      expect(items.single.price, 60);
      expect(items.single.product, isNull,
          reason: 'the item rows here carry no product');
    });

    test('removeProductOrder maps the removed item', () async {
      final recorder = _Recorder(body: jsonEncode(_itemJson()));

      final item = await _repo(recorder).removeProductOrder(
          RemoveProductOrderParam(orderId: 'o1', productId: 'p1'));

      expect(item.id, 'i1');
      expect(item.costPrice, 30);
      expect(recorder.calls.single, 'DELETE /api/pos/v1/orders/o1/products/p1');
    });

    test('removeOrderItemById maps the removed item', () async {
      final recorder =
          _Recorder(body: jsonEncode({..._itemJson(), 'order': _orderJson}));

      final item = await _repo(recorder).removeOrderItemById('i1');

      expect(item.id, 'i1');
      expect(item.order?.id, 'o1',
          reason: 'a nested order is mapped through its own extension');
      expect(recorder.calls.single, 'DELETE /api/pos/v1/orders/items/i1');
    });
  });

  group('failures', () {
    test('a 401 on the order list raises AuthException', () async {
      final recorder = _Recorder(
          status: 401, body: '{"code":"UM-401","message":"session expired"}');

      await expectLater(
        _repo(recorder).getOrderRange(
            GetOrderRangeParam(startDate: '2026-09-01', endDate: '2026-09-30')),
        throwsA(isA<AuthException>()),
      );
    });

    test('a 409 on checkout carries the message the till must show', () async {
      final recorder = _Recorder(
          status: 409, body: '{"code":"POS-409","message":"สต็อกไม่พอ"}');

      await expectLater(
        _repo(recorder).createOrder(CreateOrderParam(
          customerCode: '',
          customerName: '',
          amount: 0,
          items: [_orderItem()],
          type: 'Cash',
        )),
        throwsA(isA<ConflictException>()
            .having((e) => e.message, 'message', 'สต็อกไม่พอ')),
      );
    });
  });

  group('the checkout request body', () {
    Future<Map<String, dynamic>> bodyFor(CreateOrderParam param) async {
      final recorder = _Recorder(body: jsonEncode({'data': _orderJson}));
      await _repo(recorder).createOrder(param);
      return jsonDecode(recorder.bodies.single) as Map<String, dynamic>;
    }

    test('totals are derived from the items, not taken on trust', () async {
      final recorder = _Recorder(body: jsonEncode({'data': _orderJson}));
      await _repo(recorder).createOrder(CreateOrderParam(
        customerCode: 'C1',
        customerName: 'ลูกค้า',
        amount: 100,
        items: [_orderItem(quantity: 2)],
        type: 'Cash',
      ));

      final body = jsonDecode(recorder.bodies.single) as Map<String, dynamic>;
      expect(body['total'], 20, reason: '2 x price 10');
      expect(body['totalCost'], 10, reason: '2 x cost 5');
      expect(body['change'], 80, reason: 'amount 100 less total 20');
      expect(body['customerCode'], 'C1');
    });

    test('an explicit payment list wins over the single amount', () async {
      final body = await bodyFor(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 100,
        items: [_orderItem()],
        type: 'Cash',
        payments: [
          OrderPayment(amount: 60, type: 'Cash'),
          OrderPayment(amount: 40, type: 'Transfer'),
        ],
      ));

      expect(body['payments'], hasLength(2));
      expect(body['payments'][1]['type'], 'Transfer');
    });

    test('with no payment list one is synthesised from amount and type',
        () async {
      final body = await bodyFor(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 75,
        items: [_orderItem()],
        type: 'Transfer',
      ));

      expect(body['payments'], hasLength(1));
      expect(body['payments'].single['amount'], 75);
      expect(body['payments'].single['type'], 'Transfer');
    });

    test('a line short of stock is split across lots', () async {
      final body = await bodyFor(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 0,
        items: [
          _orderItem(
            quantity: 12,
            stocks: [_stock('stock-1', 10), _stock('stock-2', 5)],
          )
        ],
        type: 'Cash',
      ));

      final stocks = body['items'].single['stocks'] as List;
      expect(stocks, hasLength(2),
          reason: 'ten from the first lot, the remaining two from the next');
      expect(stocks[0]['quantity'], 10);
      expect(stocks[1]['quantity'], 2);
    });

    test('the printed message lists every line and the total', () async {
      final body = await bodyFor(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 0,
        items: [_orderItem(quantity: 3)],
        type: 'Cash',
      ));

      expect(body['message'], contains('ยาแก้ปวด'));
      expect(body['message'], contains('รวม 30.0 บาท'));
    });

    test('an explicit message replaces the generated one', () async {
      final body = await bodyFor(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 0,
        items: [_orderItem()],
        type: 'Cash',
        message: 'ใบเสร็จย้อนหลัง',
      ));

      expect(body['message'], 'ใบเสร็จย้อนหลัง');
    });
  });
}
