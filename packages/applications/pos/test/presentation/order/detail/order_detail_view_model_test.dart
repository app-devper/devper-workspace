import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/domain/usecase/order/get_order_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/remove_order_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/remove_order_item_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_supplier_info_use_case.dart';
import 'package:pos/presentation/order/detail/order_detail_state.dart';
import 'package:pos/presentation/order/detail/order_detail_view_model.dart';
import 'package:um/domain/repositories/login_repository.dart';

class FakeLoginRepository implements LoginRepository {
  final String role;
  final Object? getRoleThrows;

  FakeLoginRepository({this.role = 'USER', this.getRoleThrows});

  @override
  Future<String> getRole() async {
    final error = getRoleThrows;
    if (error != null) {
      throw error;
    }
    return role;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeOrderRepository implements OrderRepository {
  final OrderDetail? orderDetail;
  final OrderItemDetail? removedItem;
  final Object? getByIdThrows;
  final Object? removeThrows;
  final Object? removeItemThrows;

  FakeOrderRepository({
    this.orderDetail,
    this.removedItem,
    this.getByIdThrows,
    this.removeThrows,
    this.removeItemThrows,
  });

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    final error = getByIdThrows;
    if (error != null) {
      throw error;
    }
    return orderDetail!;
  }

  @override
  Future<OrderDetail> removeOrderById(String orderId) async {
    final error = removeThrows;
    if (error != null) {
      throw error;
    }
    return orderDetail!;
  }

  @override
  Future<OrderItemDetail> removeOrderItemById(String itemId) async {
    final error = removeItemThrows;
    if (error != null) {
      throw error;
    }
    return removedItem!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeCustomerRepository implements CustomerRepository {
  final List<Customer> customers;
  final Object? throws;

  FakeCustomerRepository({this.customers = const [], this.throws});

  @override
  Future<List<Customer>> getLocalCustomers() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return customers;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeSupplierRepository implements SupplierRepository {
  final Supplier? supplier;
  final Object? throws;

  FakeSupplierRepository({this.supplier, this.throws});

  @override
  Future<Supplier> getSupplierInfo() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return supplier!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Customer _buildCustomer(String code) {
  return Customer(
    id: 'c1',
    code: code,
    name: 'Test Customer',
    address: '',
    phone: '',
    email: '',
    status: 'Active',
    type: 'General',
  );
}

Supplier _buildSupplier() {
  return Supplier(
      id: 's1', name: 'Test Supplier', address: '', phone: '', taxId: '');
}

OrderItemDetail _buildOrderItem(String id) {
  return OrderItemDetail(
    id: id,
    product: null,
    quantity: 1,
    price: 10,
    costPrice: 5,
    discount: 0,
    createdDate: '2026-01-01T00:00:00.000Z',
    order: null,
  );
}

OrderDetail _buildOrderDetail(String id) {
  return OrderDetail(
    id: id,
    createdDate: '2026-01-01T00:00:00.000Z',
    items: const [],
    total: 100,
    totalCost: 50,
    discount: 0,
    type: 'Cash',
    code: 'O-1',
    customerCode: 'CUST-1',
    customerName: 'Test Customer',
  );
}

OrderDetailViewModel _buildViewModel({
  LoginRepository? loginRepo,
  OrderRepository? orderRepo,
  CustomerRepository? customerRepo,
  SupplierRepository? supplierRepo,
}) {
  return OrderDetailViewModel(
    getRoleUseCase: GetRoleUseCase(loginRepo ?? FakeLoginRepository()),
    getOrderByIdUseCase:
        GetOrderByIdUseCase(orderRepo: orderRepo ?? FakeOrderRepository()),
    removeOrderByIdUseCase:
        RemoveOrderByIdUseCase(orderRepo: orderRepo ?? FakeOrderRepository()),
    removeOrderItemByIdUseCase: RemoveOrderItemByIdUseCase(
        orderRepo: orderRepo ?? FakeOrderRepository()),
    getSupplierInfoUseCase: GetSupplierInfoUseCase(
        supplierRepo: supplierRepo ?? FakeSupplierRepository()),
    getLocalCustomersUseCase: GetLocalCustomersUseCase(
        customerRepo: customerRepo ?? FakeCustomerRepository()),
  );
}

void main() {
  group('checkLogin', () {
    test('sets logged true when role is ADMIN', () async {
      final vm = _buildViewModel(loginRepo: FakeLoginRepository(role: 'ADMIN'));

      await vm.checkLogin();

      expect(vm.state.value.logged, isTrue);
    });

    test('sets logged false for a non-admin role', () async {
      final vm = _buildViewModel(loginRepo: FakeLoginRepository(role: 'USER'));

      await vm.checkLogin();

      expect(vm.state.value.logged, isFalse);
    });

    test('maps a typed exception to state.error', () async {
      final vm = _buildViewModel(
        loginRepo: FakeLoginRepository(
            getRoleThrows: const NetworkException(message: 'offline')),
      );

      await vm.checkLogin();

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.logged, isNull);
    });
  });

  group('getOrderById', () {
    test('populates loaded on success', () async {
      final orderDetail = _buildOrderDetail('order-1');
      final vm = _buildViewModel(
          orderRepo: FakeOrderRepository(orderDetail: orderDetail));

      await vm.getOrderById('order-1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.loaded, orderDetail);
      expect(vm.state.value.error, isNull);

      vm.consumeLoaded();
      expect(vm.state.value.loaded, isNull);
    });

    test('maps a typed exception to state.error', () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
            getByIdThrows: const NetworkException(message: 'offline')),
      );

      await vm.getOrderById('order-1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.error, isNotNull);
    });
  });

  group('removeOrderById', () {
    test('sets removedOrder on success', () async {
      final orderDetail = _buildOrderDetail('order-1');
      final vm = _buildViewModel(
          orderRepo: FakeOrderRepository(orderDetail: orderDetail));

      await vm.removeOrderById('order-1');

      expect(vm.state.value.removedOrder, orderDetail);

      vm.consumeRemovedOrder();
      expect(vm.state.value.removedOrder, isNull);
    });

    test('maps a typed exception to state.error', () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
            removeThrows: const NetworkException(message: 'offline')),
      );

      await vm.removeOrderById('order-1');

      expect(vm.state.value.error, isNotNull);
    });
  });

  group('removeOrderItem', () {
    test('sets removedItem on success', () async {
      final removedItem = OrderItemDetail(
        id: 'item-1',
        product: null,
        quantity: 1,
        price: 10,
        costPrice: 5,
        discount: 0,
        createdDate: '2026-01-01T00:00:00.000Z',
        order: null,
      );
      final vm = _buildViewModel(
          orderRepo: FakeOrderRepository(removedItem: removedItem));

      await vm.removeOrderItem('item-1');

      expect(vm.state.value.removedItem, removedItem);

      vm.consumeRemovedItem();
      expect(vm.state.value.removedItem, isNull);
    });

    test('maps a typed exception to state.error', () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
            removeItemThrows: const NetworkException(message: 'offline')),
      );

      await vm.removeOrderItem('item-1');

      expect(vm.state.value.error, isNotNull);
    });
  });

  group('getSupplier', () {
    test('resolves both the matching customer and the supplier', () async {
      final vm = _buildViewModel(
        customerRepo: FakeCustomerRepository(
            customers: [_buildCustomer('CUST-1'), _buildCustomer('CUST-2')]),
        supplierRepo: FakeSupplierRepository(supplier: _buildSupplier()),
      );

      await vm.getSupplier('CUST-1');

      expect(vm.state.value.supplierResult, isNotNull);
      expect(vm.state.value.supplierResult!.customer!.code, 'CUST-1');
      expect(vm.state.value.supplierResult!.supplier.id, 's1');

      vm.consumeSupplierResult();
      expect(vm.state.value.supplierResult, isNull);
    });

    test('still resolves the supplier when no customer matches the code',
        () async {
      final vm = _buildViewModel(
        customerRepo:
            FakeCustomerRepository(customers: [_buildCustomer('OTHER')]),
        supplierRepo: FakeSupplierRepository(supplier: _buildSupplier()),
      );

      await vm.getSupplier('CUST-1');

      expect(vm.state.value.supplierResult, isNotNull);
      expect(vm.state.value.supplierResult!.customer, isNull);
    });

    test('still resolves the supplier when the customer lookup throws',
        () async {
      final vm = _buildViewModel(
        customerRepo: FakeCustomerRepository(
            throws: const NetworkException(message: 'offline')),
        supplierRepo: FakeSupplierRepository(supplier: _buildSupplier()),
      );

      await vm.getSupplier('CUST-1');

      expect(vm.state.value.supplierResult, isNotNull);
      expect(vm.state.value.supplierResult!.customer, isNull);
      expect(vm.state.value.supplierError, isNull);
    });

    test(
        'maps a typed exception from the supplier lookup to state.supplierError',
        () async {
      final vm = _buildViewModel(
        customerRepo:
            FakeCustomerRepository(customers: [_buildCustomer('CUST-1')]),
        supplierRepo: FakeSupplierRepository(
            throws: const NetworkException(message: 'offline')),
      );

      await vm.getSupplier('CUST-1');

      expect(vm.state.value.supplierError, isNotNull);
      expect(vm.state.value.supplierResult, isNull);

      vm.consumeSupplierError();
      expect(vm.state.value.supplierError, isNull);
    });
  });

  test('updateTotalCost / consumeTotalCostUpdated toggles the one-shot flag',
      () {
    final vm = _buildViewModel();

    vm.updateTotalCost();
    expect(vm.state.value.totalCostUpdated, isTrue);

    vm.consumeTotalCostUpdated();
    expect(vm.state.value.totalCostUpdated, isFalse);
  });

  group('one task at a time', () {
    test('reloading after removing an item drops the stale delete result',
        () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
          orderDetail: _buildOrderDetail('order-1'),
          removedItem: _buildOrderItem('item-1'),
        ),
      );

      await vm.removeOrderItem('item-1');
      expect(vm.state.value.removedItem, isNotNull);

      await vm.getOrderById('order-1');

      expect(vm.state.value.loaded, isNotNull);
      expect(vm.state.value.removedItem, isNull,
          reason:
              'a delete result must not survive the reload that follows it');
      expect(vm.state.value.task, isA<OrderLoaded>());
    });

    test('deleting the order drops a stale loaded document', () async {
      final vm = _buildViewModel(
        orderRepo:
            FakeOrderRepository(orderDetail: _buildOrderDetail('order-1')),
      );

      await vm.getOrderById('order-1');
      expect(vm.state.value.loaded, isNotNull);

      await vm.removeOrderById('order-1');

      expect(vm.state.value.removedOrder, isNotNull);
      expect(vm.state.value.loaded, isNull);
    });

    test('a failure leaves no result behind', () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
          orderDetail: _buildOrderDetail('order-1'),
          removeThrows: const NetworkException(message: 'offline'),
        ),
      );

      await vm.getOrderById('order-1');
      expect(vm.state.value.loaded, isNotNull);

      await vm.removeOrderById('order-1');

      expect(vm.state.value.error, isNotNull);
      expect(vm.state.value.loaded, isNull);
      expect(vm.state.value.removedOrder, isNull);
      expect(vm.state.value.loading, isFalse);
    });
  });

  group('supplier lookup', () {
    test('a found profile and a missing one cannot both be present', () async {
      final vm = _buildViewModel(
        supplierRepo: FakeSupplierRepository(
            throws: const NetworkException(message: 'offline')),
      );

      await vm.getSupplier('C1');

      expect(vm.state.value.supplierError, isNotNull);
      expect(vm.state.value.supplierResult, isNull);
      expect(vm.state.value.supplier, isA<SupplierNotConfigured>());

      vm.consumeSupplierError();

      expect(vm.state.value.supplier, isA<SupplierLookupIdle>());
    });

    test('the supplier lookup does not disturb the order task', () async {
      final vm = _buildViewModel(
        orderRepo:
            FakeOrderRepository(orderDetail: _buildOrderDetail('order-1')),
        supplierRepo: FakeSupplierRepository(
            throws: const NetworkException(message: 'offline')),
      );

      await vm.getOrderById('order-1');
      await vm.getSupplier('C1');

      expect(vm.state.value.loaded, isNotNull,
          reason: 'the two flows have separate slots');
      expect(vm.state.value.error, isNull);
      expect(vm.state.value.supplierError, isNotNull);
    });
  });
}
