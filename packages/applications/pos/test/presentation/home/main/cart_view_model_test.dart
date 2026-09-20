import 'dart:async';

import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/order/create_order_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_use_case.dart';
import 'package:pos/domain/model/sale/till.dart';
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
  final List<CreateOrderParam> sent = [];

  FakeOrderRepository({this.result, this.createThrows, this.gate});

  @override
  Future<OrderResult> createOrder(CreateOrderParam param) async {
    createCalls++;
    sent.add(param);
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
  Till? till,
}) {
  return CartViewModel(
    till: till ?? Till(),
    createOrderUseCase: CreateOrderUseCase(orderRepo: orderRepo),
    getProductByBarcodeUseCase:
        GetProductByBarcodeUseCase(productRepo: productRepo),
    updateProductStockUseCase:
        UpdateProductStockUseCase(productRepo: productRepo),
  );
}

void main() {
  // What a Sale decides — prices, totals, whether the money covers it — is
  // tested in test/domain/model/sale/sale_test.dart, with no fakes. What is
  // left here is what this module owns: the lookup, the request, the channels.

  group('addOrderItem', () {
    test('looks the barcode up and puts what came back on the sale', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.orderItems!.first.product.unit.barcode, '111');
      expect(vm.state.value.total, greaterThan(0));
    });

    test('a barcode already on the sale is not looked up again', () async {
      final repo = FakeProductRepository(product: _buildProduct('111'));
      final vm = _buildViewModel(
        productRepo: repo,
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      await vm.addOrderItem('111');

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.orderItems!.first.quantity, 2);
      expect(repo.barcodeLookups, ['111'],
          reason: 'the second scan is answered from the sale');
    });

    test('a barcode nothing matches reports a miss', () async {
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

    test('a failed lookup goes out on the lookup channel', () async {
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

  group('checkout', () {
    test('sends the sale and applies a stock update for every stock back',
        () async {
      final productRepo = FakeProductRepository(product: _buildProduct('111'));
      final orderResult = OrderResult(
        data: _buildOrder(),
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

      await vm.addOrderItem('111');
      await vm.checkout(tendered: 100, type: 'Cash');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.orderSaving, isFalse);
      expect(placed.single, orderResult);
      expect(errors, isEmpty);
      expect(productRepo.updatedStocks.map((e) => e.id),
          containsAll(['stock-1', 'stock-2']));
    });

    test('the request carries what the sale holds', () async {
      final orderRepo = FakeOrderRepository(result: _buildOrderResult());
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: orderRepo,
      );

      await vm.addOrderItem('111');
      vm.setCompliance(patientId: 'P-1');
      await vm.checkout(tendered: 50, type: 'PromptPay');

      final sent = orderRepo.sent.single;
      expect(sent.items, hasLength(1));
      expect(sent.amount, 50);
      expect(sent.type, 'PromptPay');
      expect(sent.patientId, 'P-1',
          reason: 'the page used to assemble this itself');
    });

    test('money that does not cover the sale is refused before the request',
        () async {
      final orderRepo = FakeOrderRepository(result: _buildOrderResult());
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: orderRepo,
      );
      final errors = <String>[];
      vm.checkoutErrors.listen(errors.add);

      await vm.addOrderItem('111');
      await vm.checkout(tendered: 1, type: 'Cash');
      await Future<void>.delayed(Duration.zero);

      expect(orderRepo.createCalls, 0,
          reason: 'this rule used to live in the payment widget');
      expect(errors, hasLength(1));
      expect(vm.state.value.orderSaving, isFalse);
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

      await vm.addOrderItem('111');
      await vm.checkout(tendered: 100, type: 'Cash');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.orderSaving, isFalse);
      expect(errors, hasLength(1));
      expect(placed, isEmpty);
      expect(productRepo.updatedStocks, isEmpty);
    });

    test('a second submit while one is in flight is ignored', () async {
      final gate = Completer<void>();
      final orderRepo =
          FakeOrderRepository(result: _buildOrderResult(), gate: gate);
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: orderRepo,
      );

      await vm.addOrderItem('111');
      final first = vm.checkout(tendered: 100, type: 'Cash');
      await vm.checkout(tendered: 100, type: 'Cash');
      gate.complete();
      await first;

      expect(orderRepo.createCalls, 1,
          reason: 'a double submit would bill the customer twice');
    });

    test('a completed sale is delivered once', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(result: _buildOrderResult()),
      );
      final placed = <OrderResult>[];
      vm.orderPlaced.listen(placed.add);

      await vm.addOrderItem('111');
      await vm.checkout(tendered: 100, type: 'Cash');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(placed, hasLength(1));
    });
  });

  group('the till', () {
    test('a scanned line is held by the sale, not just drawn', () async {
      final till = Till();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        till: till,
      );

      await vm.addOrderItem('111');

      expect(vm.state.value.orderItems, hasLength(1));
      expect(till.open.lines, hasLength(1),
          reason: 'the view used to be handed a copy and edit that instead');
    });

    test('parking a sale and coming back keeps its lines', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      vm.selectCart(1);

      expect(vm.state.value.orderItems, isEmpty,
          reason: 'the second slot is its own sale');
      expect(vm.state.value.total, 0);

      vm.selectCart(0);

      expect(vm.state.value.orderItems, hasLength(1));
      expect(vm.state.value.total, greaterThan(0));
    });

    test('re-reading the open sale does not empty it', () async {
      // prepareData() is what runs on resume.
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      vm.prepareData();

      expect(vm.state.value.orderItems, hasLength(1));
    });

    test('each slot keeps its own customer and lines', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      vm.setCustomer(_buildCustomer());
      vm.selectCart(3);
      await vm.addOrderItem('111');

      expect(vm.customer, isNull, reason: 'a new slot is a new customer');

      vm.selectCart(0);

      expect(vm.customer?.code, 'CUST-1');
      expect(vm.state.value.orderItems, hasLength(1));
    });

    test('a slot the till does not have is ignored', () {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(),
        orderRepo: FakeOrderRepository(),
      );

      vm.selectCart(99);

      expect(vm.openCart, 0);
    });

    test('clearing empties only the open sale', () async {
      final till = Till();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        till: till,
      );

      await vm.addOrderItem('111');
      vm.selectCart(1);
      await vm.addOrderItem('111');
      vm.clearCart();

      expect(vm.state.value.orderItems, isEmpty);
      expect(vm.cartHasLines(0), isTrue);
      expect(vm.cartHasLines(1), isFalse);
    });

    test('the list the view renders is not the list the sale holds', () async {
      final till = Till();
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
        till: till,
      );

      await vm.addOrderItem('111');
      vm.state.value.orderItems!.clear();

      expect(till.open.lines, hasLength(1),
          reason: 'a view that drops its copy must not drop the sale');
    });
  });

  group('editing lines', () {
    test('reducing the last one takes the line off and retotals', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      vm.minusItem(0);

      expect(vm.state.value.orderItems, isEmpty);
      expect(vm.state.value.total, 0);
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

    test('picking a customer retotals what is on screen', () async {
      final vm = _buildViewModel(
        productRepo: FakeProductRepository(product: _buildProduct('111')),
        orderRepo: FakeOrderRepository(),
      );

      await vm.addOrderItem('111');
      final before = vm.state.value.total;

      vm.setCustomer(_buildCustomer());

      expect(vm.state.value.total, isNot(before),
          reason: 'the screen showed the old total before this');
    });
  });
}

Order _buildOrder() {
  return Order(
    id: 'order-1',
    code: 'O-1',
    customerCode: '',
    customerName: '',
    createdDate: '',
    total: 100,
    totalCost: 50,
    discount: 0,
    type: 'Cash',
  );
}

OrderResult _buildOrderResult() {
  return OrderResult(data: _buildOrder(), stocks: [_buildStock('stock-1', 5)]);
}

Customer _buildCustomer() {
  return Customer(
    id: 'c-1',
    code: 'CUST-1',
    name: 'ร้านยาแถวบ้าน',
    address: '',
    phone: '',
    email: '',
    status: 'Active',
    type: customerTypeWholesaler,
  );
}
