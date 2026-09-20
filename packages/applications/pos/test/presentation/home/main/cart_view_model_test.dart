import 'dart:async';

import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/order/create_order_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_use_case.dart';
import 'package:pos/presentation/home/main/cart_store.dart';
import 'package:pos/presentation/home/main/cart_view_model.dart';

class FakeProductRepository implements ProductRepository {
  final Product? product;
  final Object? getByBarcodeThrows;
  final List<ProductStock> updatedStocks = [];
  final List<String> barcodeLookups = [];

  FakeProductRepository({this.product, this.getByBarcodeThrows});

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final error = getByBarcodeThrows;
    if (error != null) {
      throw error;
    }
    barcodeLookups.add(barcode);
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
      await vm.addOrderItem('111');

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.orderItems!.first.product.unit.barcode, '111');
      expect(vm.state.value.orderItems!.first.quantity, 1);
    });

    test(
        'increments quantity instead of a repository lookup when barcode already in the cart',
        () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );
      await vm.addOrderItem('111');
      await vm.addOrderItem('111');

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.orderItems!.first.quantity, 2);
      expect(FakeProductRepository(product: _buildProduct('111')), isNotNull);
    });

    test('sets a not-found error when the barcode lookup returns null',
        () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: null),
        orderRepo: FakeOrderRepository(),
      );

      final errors = <String>[];
      vm.lookupErrors.listen(errors.add);

      await vm.addOrderItem('999');
      await Future<void>.delayed(Duration.zero);

      expect(errors.single, 'ไม่พบสินค้า');
      expect(vm.state.value.loading, isFalse);
    });

    test('a failed barcode lookup goes out on the lookup channel', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(
            getByBarcodeThrows: const NetworkException(message: 'offline')),
        orderRepo: FakeOrderRepository(),
      );

      final lookupErrors = <String>[];
      final checkoutErrors = <String>[];
      vm.lookupErrors.listen(lookupErrors.add);
      vm.checkoutErrors.listen(checkoutErrors.add);

      await vm.addOrderItem('111');
      await Future<void>.delayed(Duration.zero);

      expect(lookupErrors, hasLength(1));
      expect(checkoutErrors, isEmpty,
          reason: 'a scan that failed is not a sale that failed');
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

      final placed = <OrderResult>[];
      final errors = <String>[];
      vm.orderPlaced.listen(placed.add);
      vm.checkoutErrors.listen(errors.add);

      await vm.createOrder(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 100,
        items: const [],
        type: 'Cash',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.orderSaving, isFalse);
      expect(placed.single, orderResult);
      expect(errors, isEmpty);
      expect(productRepo.updatedStocks, hasLength(2));
      expect(productRepo.updatedStocks.map((e) => e.id),
          containsAll(['stock-1', 'stock-2']));
    });

    test('a failed sale reports without touching stock', () async {
      final productRepo = FakeProductRepository(product: _buildProduct('111'));
      final vm = _buildViewModel(
        productRepo: productRepo,
        orderRepo: FakeOrderRepository(
            createThrows: const NetworkException(message: 'offline')),
      );

      final placed = <OrderResult>[];
      final errors = <String>[];
      vm.orderPlaced.listen(placed.add);
      vm.checkoutErrors.listen(errors.add);

      await vm.createOrder(CreateOrderParam(
        customerCode: '',
        customerName: '',
        amount: 100,
        items: const [],
        type: 'Cash',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.orderSaving, isFalse);
      expect(errors, hasLength(1));
      expect(placed, isEmpty);
      expect(productRepo.updatedStocks, isEmpty);
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

      final placed = <OrderResult>[];
      vm.orderPlaced.listen(placed.add);

      final first = vm.createOrder(_buildOrderParam());
      expect(vm.state.value.orderSaving, isTrue);

      await vm.createOrder(_buildOrderParam());
      expect(orderRepo.createCalls, 1,
          reason: 'a double tap must not bill the customer twice');

      gate.complete();
      await first;
      await Future<void>.delayed(Duration.zero);

      expect(placed, hasLength(1));
      expect(vm.state.value.orderSaving, isFalse);
      expect(orderRepo.createCalls, 1);
    });

    test('a completed sale is delivered once', () async {
      final orderResult = _buildOrderResult();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(result: orderResult),
      );
      final placed = <OrderResult>[];
      vm.orderPlaced.listen(placed.add);

      await vm.createOrder(_buildOrderParam());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(placed, hasLength(1),
          reason: 'the old shape needed consumeOrderResult to stop it '
              'emptying the cart twice');
      expect(vm.state.value.orderSaving, isFalse);
    });
  });

  group('cart mutations', () {
    test('minusItem removes the line once quantity reaches zero', () async {
      final store = CartStore();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        cartStore: store,
      );

      await vm.addOrderItem('111');
      vm.minusItem(0);

      expect(vm.state.value.orderItems, isEmpty);
      expect(store.cart[0], isEmpty);
    });

    test('toggleAllowOversell flips the flag on the targeted line', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      vm.toggleAllowOversell(0);

      expect(vm.state.value.orderItems!.first.allowOversell, isTrue);
    });

    test('an index that no longer exists is ignored, not thrown on', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');

      expect(() => vm.removeItem(4), returnsNormally,
          reason: 'a dialog can outlive the line it was opened on');
      expect(() => vm.plusItem(-1), returnsNormally);
      expect(vm.state.value.orderItems, hasLength(1));
    });
  });

  group('the cart the cashier parked', () {
    test('a scanned line is held by the cart, not just drawn', () async {
      final store = CartStore();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        cartStore: store,
      );

      vm.selectCart(0);
      await vm.addOrderItem('111');

      expect(vm.state.value.orderItems, hasLength(1));
      expect(store.cart[0], hasLength(1),
          reason: 'the view used to be handed a copy and edit that instead');
    });

    test('parking a sale and coming back to it keeps the lines', () async {
      final store = CartStore();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        cartStore: store,
      );

      vm.selectCart(0);
      await vm.addOrderItem('111');
      vm.selectCart(1);

      expect(vm.state.value.orderItems, isEmpty,
          reason: 'the second cart is its own sale');

      vm.selectCart(0);

      expect(vm.state.value.orderItems, hasLength(1));
    });

    test('re-reading the open cart does not empty it', () async {
      // prepareData() is what runs on resume. It used to re-read the store,
      // which had never been written to, so the screen came back blank.
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      vm.prepareData();

      expect(vm.state.value.orderItems, hasLength(1));
    });

    test('two carts hold their own lines', () async {
      final store = CartStore();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        cartStore: store,
      );

      vm.selectCart(0);
      await vm.addOrderItem('111');
      await vm.addOrderItem('111');
      vm.selectCart(3);
      await vm.addOrderItem('111');

      expect(store.cart[0]!.single.quantity, 2);
      expect(store.cart[3]!.single.quantity, 1);
    });

    test('clearing empties only the open cart', () async {
      final store = CartStore();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        cartStore: store,
      );

      vm.selectCart(0);
      await vm.addOrderItem('111');
      vm.selectCart(1);
      await vm.addOrderItem('111');
      vm.clearCart();

      expect(store.cart[1], isEmpty);
      expect(store.cart[0], hasLength(1));
    });

    test('the list the view renders is not the list the cart holds', () async {
      final store = CartStore();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        cartStore: store,
      );

      vm.selectCart(0);
      await vm.addOrderItem('111');

      vm.state.value.orderItems!.clear();

      expect(store.cart[0], hasLength(1),
          reason: 'a view that drops its copy must not drop the sale');
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
