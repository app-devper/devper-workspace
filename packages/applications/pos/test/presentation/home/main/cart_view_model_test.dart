import 'dart:async';

import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/order/create_order_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_use_case.dart';
import 'package:pos/presentation/home/main/cart_store.dart';
import 'package:pos/presentation/home/main/cart_state.dart';
import 'package:pos/presentation/home/main/cart_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final Product? product;
  final Object? getByBarcodeThrows;
  final List<ProductStock> updatedStocks = [];

  FakeProductRepository({this.product, this.getByBarcodeThrows});

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final error = getByBarcodeThrows;
    if (error != null) {
      throw error;
    }
    return product;
  }

  @override
  Future<void> updateProductStock(ProductStock element) async {
    updatedStocks.add(element);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeOrderRepository implements OrderRepository {
  final OrderResult? result;
  final Object? createThrows;

  /// Holds createOrder open so a test can submit again mid-flight.
  final Completer<void>? gate;
  int createCalls = 0;

  FakeOrderRepository({this.result, this.createThrows, this.gate});

  @override
  Future<OrderResult> createOrder(CreateOrderParam param) async {
    createCalls++;
    await gate?.future;
    final error = createThrows;
    if (error != null) {
      throw error;
    }
    return result!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductUnit _buildUnit(String barcode) {
  return ProductUnit(
    id: 'unit-1',
    productId: 'product-1',
    costPrice: 5,
    unit: 'เม็ด',
    size: 1,
    barcode: barcode,
    volume: 0,
    volumeUnit: '',
  );
}

ProductStock _buildStock(String id, int quantity) {
  return ProductStock(
    id: id,
    unitId: 'unit-1',
    productId: 'product-1',
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
}

Product _buildProduct(String barcode, {List<ProductStock>? stocks}) {
  return Product(
    id: 'product-1',
    name: 'Test Product',
    status: productStatusActive,
    category: 'General',
    createdDate: '',
    units: [_buildUnit(barcode)],
    prices: const [],
    stocks: stocks ?? [_buildStock('stock-1', 10)],
  );
}

CartViewModel _buildViewModel({
  required ProductRepository productRepo,
  required OrderRepository orderRepo,
  CartStore? cartStore,
}) {
  return CartViewModel(
    cartStore: cartStore ?? CartStore(),
    createOrderUseCase: CreateOrderUseCase(orderRepo: orderRepo),
    getProductByBarcodeUseCase:
        GetProductByBarcodeUseCase(productRepo: productRepo),
    updateProductStockUseCase:
        UpdateProductStockUseCase(productRepo: productRepo),
  );
}

void main() {
  group('addOrderItem', () {
    test(
        'looks up the barcode and adds a new item when not already in the cart',
        () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );
      final orderItems = <OrderItem>[];

      await vm.addOrderItem('111', orderItems);

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.orderItems!.first.product.unit.barcode, '111');
      expect(vm.state.value.orderItems!.first.quantity, 1);
      expect(vm.state.value.error, isNull);
    });

    test(
        'increments quantity instead of a repository lookup when barcode already in the cart',
        () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );
      final existing = OrderItem(
        product: _buildProduct('111').toProductItems().first,
        quantity: 1,
        customerType: priceTypeStock,
      );
      final orderItems = [existing];

      await vm.addOrderItem('111', orderItems);

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.orderItems!.first.quantity, 2);
    });

    test('sets a not-found error when the barcode lookup returns null',
        () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: null),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('999', <OrderItem>[]);

      expect(vm.state.value.error, 'ไม่พบสินค้า');
      expect(vm.state.value.loading, isFalse);
    });

    test('maps a typed exception from the barcode lookup to state.error',
        () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(
            getByBarcodeThrows: const NetworkException(message: 'offline')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111', <OrderItem>[]);

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.loading, isFalse);
    });
  });

  group('createOrder', () {
    test('saves the order and applies a stock update for every returned stock',
        () async {
      final productRepo = FakeProductRepository(product: _buildProduct('111'));
      final orderResult = OrderResult(
        data: Order(
          id: 'order-1',
          code: 'O-1',
          customerCode: '',
          customerName: '',
          createdDate: '',
          total: 100,
          totalCost: 50,
          discount: 0,
          type: 'Cash',
        ),
        stocks: [_buildStock('stock-1', 5), _buildStock('stock-2', 3)],
      );
      final vm = _buildViewModel(
        productRepo: productRepo,
        orderRepo: FakeOrderRepository(result: orderResult),
      );

      await vm.createOrder(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 100,
        items: const [],
        type: 'Cash',
      ));

      expect(vm.state.value.orderSaving, isFalse);
      expect(vm.state.value.orderResult, orderResult);
      expect(vm.state.value.orderError, isNull);
      expect(productRepo.updatedStocks, hasLength(2));
      expect(productRepo.updatedStocks.map((e) => e.id),
          containsAll(['stock-1', 'stock-2']));
    });

    test('maps a typed exception to state.orderError without touching stock',
        () async {
      final productRepo = FakeProductRepository(product: _buildProduct('111'));
      final vm = _buildViewModel(
        productRepo: productRepo,
        orderRepo: FakeOrderRepository(
            createThrows: const NetworkException(message: 'offline')),
      );

      await vm.createOrder(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 100,
        items: const [],
        type: 'Cash',
      ));

      expect(vm.state.value.orderSaving, isFalse);
      expect(vm.state.value.orderError, isNotNull);
      expect(productRepo.updatedStocks, isEmpty);

      vm.consumeOrderError();
      expect(vm.state.value.orderError, isNull);
      expect(vm.state.value.checkout, isA<CheckoutIdle>());
    });

    test('a second submit while one is in flight is ignored', () async {
      final gate = Completer<void>();
      final orderRepo = FakeOrderRepository(
        result: _buildOrderResult(),
        gate: gate,
      );
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: orderRepo,
      );

      final first = vm.createOrder(_buildOrderParam());
      expect(vm.state.value.checkout, isA<CheckoutSubmitting>());

      await vm.createOrder(_buildOrderParam());
      expect(orderRepo.createCalls, 1,
          reason: 'a double tap must not bill the customer twice');

      gate.complete();
      await first;

      expect(vm.state.value.checkout, isA<CheckoutSucceeded>());
      expect(orderRepo.createCalls, 1);
    });

    test('consuming the result returns checkout to idle', () async {
      final orderResult = _buildOrderResult();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(result: orderResult),
      );

      await vm.createOrder(_buildOrderParam());
      expect(vm.state.value.orderResult, orderResult);

      vm.consumeOrderResult();

      expect(vm.state.value.checkout, isA<CheckoutIdle>());
      expect(vm.state.value.orderResult, isNull);
      expect(vm.state.value.orderSaving, isFalse);
    });
  });

  group('cart mutations', () {
    test('minusItem removes the item once quantity reaches zero', () {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(),
        orderRepo: FakeOrderRepository(),
      );
      final item = OrderItem(
        product: _buildProduct('111').toProductItems().first,
        quantity: 1,
        customerType: priceTypeStock,
      );
      final orderItems = [item];

      vm.minusItem(0, orderItems);

      expect(vm.state.value.orderItems, isEmpty);
    });

    test('toggleAllowOversell flips the flag on the targeted item', () {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(),
        orderRepo: FakeOrderRepository(),
      );
      final item = OrderItem(
        product: _buildProduct('111').toProductItems().first,
        quantity: 1,
        customerType: priceTypeStock,
      );
      final orderItems = [item];

      vm.toggleAllowOversell(0, orderItems);

      expect(vm.state.value.orderItems!.first.allowOversell, isTrue);
    });
  });
}

OrderResult _buildOrderResult() {
  return OrderResult(
    data: Order(
      id: 'order-1',
      code: 'O-1',
      customerCode: '',
      customerName: '',
      createdDate: '',
      total: 100,
      totalCost: 50,
      discount: 0,
      type: 'Cash',
    ),
    stocks: [_buildStock('stock-1', 5)],
  );
}

CreateOrderParam _buildOrderParam() {
  return CreateOrderParam(
    customerCode: '',
    customerName: '',
    amount: 100,
    items: const [],
    type: 'Cash',
  );
}
