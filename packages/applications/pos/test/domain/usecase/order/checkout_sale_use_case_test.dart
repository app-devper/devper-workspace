import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/sale/sale.dart';
import 'package:pos/domain/model/sale/till.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/usecase/order/checkout_sale_use_case.dart';

class RecordingOrders implements OrderRepository {
  final gate = Completer<void>();
  final requests = <CreateOrderParam>[];
  Object? failure;

  @override
  Future<OrderResult> createOrder(CreateOrderParam param) async {
    requests.add(param);
    await gate.future;
    if (failure != null) throw failure!;
    return OrderResult(
      data: Order(
          id: 'recorded',
          code: 'OD-1',
          customerCode: '',
          customerName: '',
          createdDate: '',
          total: 10,
          totalCost: 5,
          discount: 0,
          type: 'Cash'),
      stocks: [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Sale saleWithLine() => Sale()
  ..addLine(ProductUnitItem(
    id: 'product',
    name: 'Product',
    category: '',
    status: 'ACTIVE',
    createdDate: '',
    unit: ProductUnit(
        id: 'unit',
        productId: 'product',
        costPrice: 5,
        unit: 'TAB',
        size: 1,
        barcode: '111',
        volume: 0,
        volumeUnit: ''),
    prices: [],
    stocks: [
      ProductStock(
          id: 'stock',
          unitId: 'unit',
          productId: 'product',
          receiveCode: '',
          sequence: 1,
          lotNumber: '',
          costPrice: 5,
          price: 10,
          import: 5,
          quantity: 5,
          expireDate: '',
          importDate: '')
    ],
  ));

void main() {
  test('completion belongs to the submitted Sale, without a view listener',
      () async {
    final till = Till();
    till.open.addLine(saleWithLine().lines.single.product);
    final submitted = till.open;
    final originalId = submitted.id;
    final orders = RecordingOrders();
    final checkout = CheckoutSaleUseCase(orderRepo: orders);
    final pending = checkout(submitted, tendered: 20, type: 'Cash');
    expect(checkout.isSubmitting(submitted), isTrue);
    till.switchTo(1);
    till.open.addLine(saleWithLine().lines.single.product);
    final parked = till.open;
    orders.gate.complete();
    expect(await pending, isA<SaleCheckoutRecorded>());
    expect(submitted.isEmpty, isTrue);
    expect(submitted.id, isNot(originalId));
    expect(orders.requests.single.saleId, originalId);
    expect(parked.lines, hasLength(1));
    expect(checkout.isSubmitting(submitted), isFalse);
  });

  test('failed recording leaves the Sale and id for retry', () async {
    final sale = saleWithLine();
    final id = sale.id;
    final orders = RecordingOrders()..failure = StateError('connection lost');
    final checkout = CheckoutSaleUseCase(orderRepo: orders);
    final pending = checkout(sale, tendered: 20, type: 'Cash');
    orders.gate.complete();
    await expectLater(pending, throwsStateError);
    expect(sale.lines, hasLength(1));
    expect(sale.id, id);
    expect(checkout.isSubmitting(sale), isFalse);
    orders.failure = null;
    expect(await checkout(sale, tendered: 20, type: 'Cash'),
        isA<SaleCheckoutRecorded>());
    expect(orders.requests.map((request) => request.saleId), [id, id]);
  });

  test('two callers cannot record the same pending Sale', () async {
    final sale = saleWithLine();
    final orders = RecordingOrders();
    final checkout = CheckoutSaleUseCase(orderRepo: orders);
    final pending = checkout(sale, tendered: 20, type: 'Cash');
    expect(await checkout(sale, tendered: 20, type: 'Cash'),
        isA<SaleCheckoutPending>());
    expect(orders.requests, hasLength(1));
    orders.gate.complete();
    await pending;
  });

  test('invalid tender or empty Sale never reaches recording', () async {
    final orders = RecordingOrders();
    final checkout = CheckoutSaleUseCase(orderRepo: orders);
    for (final tender in [1.0, double.nan, double.infinity]) {
      expect(await checkout(saleWithLine(), tendered: tender, type: 'Cash'),
          isA<SaleCheckoutRejected>());
    }
    expect(await checkout(Sale(), tendered: 20, type: 'Cash'),
        isA<SaleCheckoutRejected>());
    expect(orders.requests, isEmpty);
  });
}
