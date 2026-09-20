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

  final List<String> loadedOrderIds = [];
  final List<String> removedOrderIds = [];
  final List<String> removedItemIds = [];

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
    loadedOrderIds.add(orderId);
    return orderDetail!;
  }

  @override
  Future<OrderDetail> removeOrderById(String orderId) async {
    final error = removeThrows;
    if (error != null) {
      throw error;
    }
    removedOrderIds.add(orderId);
    return orderDetail!;
  }

  @override
  Future<OrderItemDetail> removeOrderItemById(String itemId) async {
    final error = removeItemThrows;
    if (error != null) {
      throw error;
    }
    removedItemIds.add(itemId);
    return removedItem!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Serves the document once and then goes offline, so a refresh can fail while
/// the screen already has something on it.
class FailOnSecondLoadRepository implements OrderRepository {
  final OrderDetail orderDetail;
  int _calls = 0;

  FailOnSecondLoadRepository(this.orderDetail);

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    if (_calls++ > 0) {
      throw const NetworkException(message: 'offline');
    }
    return orderDetail;
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
    customerRepo: customerRepo ?? FakeCustomerRepository(),
  );
}

void main() {
  group('checkLogin', () {
    test('an admin gets the admin actions', () async {
      final vm = _buildViewModel(loginRepo: FakeLoginRepository(role: 'ADMIN'));

      await vm.checkLogin();

      expect(vm.state.value.isAdmin, isTrue);
    });

    test('any other role does not', () async {
      final vm = _buildViewModel(loginRepo: FakeLoginRepository(role: 'USER'));

      await vm.checkLogin();

      expect(vm.state.value.isAdmin, isFalse);
    });

    test('a role that cannot be read leaves the screen as a cashier', () async {
      final vm = _buildViewModel(
        loginRepo: FakeLoginRepository(
            getRoleThrows: const NetworkException(message: 'offline')),
      );
      final errors = <String>[];
      vm.errors.listen(errors.add);

      await vm.checkLogin();
      await _pump();

      expect(vm.state.value.isAdmin, isFalse,
          reason: 'an unreadable role must not unlock deleting orders');
      expect(errors, hasLength(1));
    });
  });

  group('getOrderById', () {
    test('puts the document on the screen', () async {
      final orderDetail = _buildOrderDetail('order-1');
      final vm = _buildViewModel(
          orderRepo: FakeOrderRepository(orderDetail: orderDetail));

      await vm.getOrderById('order-1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.order, orderDetail);
    });

    test('a failure is reported and stops the spinner', () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
            getByIdThrows: const NetworkException(message: 'offline')),
      );
      final errors = <String>[];
      vm.errors.listen(errors.add);

      await vm.getOrderById('order-1');
      await _pump();

      expect(vm.state.value.loading, isFalse);
      expect(errors, hasLength(1));
    });

    test('a failed reload keeps the document already on screen', () async {
      final repo = FailOnSecondLoadRepository(_buildOrderDetail('order-1'));
      final vm = _buildViewModel(orderRepo: repo);
      final errors = <String>[];
      vm.errors.listen(errors.add);

      await vm.getOrderById('order-1');
      await vm.getOrderById('order-1');
      await _pump();

      expect(errors, hasLength(1));
      expect(vm.state.value.order, isNotNull,
          reason: 'a failed refresh must not blank the order the user is '
              'reading');
    });
  });

  group('removeOrderById', () {
    test('announces the removal so the screen can pop with it', () async {
      final orderDetail = _buildOrderDetail('order-1');
      final vm = _buildViewModel(
          orderRepo: FakeOrderRepository(orderDetail: orderDetail));
      final removals = <OrderDetail>[];
      vm.removals.listen(removals.add);

      await vm.removeOrderById('order-1');
      await _pump();

      expect(removals, [orderDetail]);
      expect(vm.state.value.loading, isFalse);
    });

    test('a failure is reported and nothing is removed', () async {
      final vm = _buildViewModel(
        orderRepo: FakeOrderRepository(
            removeThrows: const NetworkException(message: 'offline')),
      );
      final removals = <OrderDetail>[];
      final errors = <String>[];
      vm.removals.listen(removals.add);
      vm.errors.listen(errors.add);

      await vm.removeOrderById('order-1');
      await _pump();

      expect(errors, hasLength(1));
      expect(removals, isEmpty);
    });
  });

  group('removeOrderItem', () {
    test('reloads the document, because every total on it changed', () async {
      final repo = FakeOrderRepository(
        orderDetail: _buildOrderDetail('order-1'),
        removedItem: _buildOrderItem('item-1'),
      );
      final vm = _buildViewModel(orderRepo: repo);

      await vm.removeOrderItem('order-1', 'item-1');

      expect(repo.removedItemIds, ['item-1']);
      expect(repo.loadedOrderIds, ['order-1'],
          reason: 'the reload used to be a second call the page made itself');
      expect(vm.state.value.order, isNotNull);
      expect(vm.state.value.loading, isFalse);
    });

    test('a failed delete is reported and does not reload', () async {
      final repo = FakeOrderRepository(
        orderDetail: _buildOrderDetail('order-1'),
        removeItemThrows: const NetworkException(message: 'offline'),
      );
      final vm = _buildViewModel(orderRepo: repo);
      final errors = <String>[];
      vm.errors.listen(errors.add);

      await vm.removeOrderItem('order-1', 'item-1');
      await _pump();

      expect(errors, hasLength(1));
      expect(repo.loadedOrderIds, isEmpty);
      expect(vm.state.value.loading, isFalse,
          reason: 'the screen must not be left holding a spinner');
    });
  });

  group('getSupplier', () {
    test('resolves both the matching customer and the shop profile', () async {
      final vm = _buildViewModel(
        customerRepo: FakeCustomerRepository(
            customers: [_buildCustomer('CUST-1'), _buildCustomer('CUST-2')]),
        supplierRepo: FakeSupplierRepository(supplier: _buildSupplier()),
      );
      final receipts = <SupplierResult>[];
      vm.receipts.listen(receipts.add);

      await vm.getSupplier('CUST-1');
      await _pump();

      expect(receipts, hasLength(1));
      expect(receipts.single.customer!.code, 'CUST-1');
      expect(receipts.single.supplier.id, 's1');
    });

    test('prints without a customer when no code matches', () async {
      final vm = _buildViewModel(
        customerRepo:
            FakeCustomerRepository(customers: [_buildCustomer('OTHER')]),
        supplierRepo: FakeSupplierRepository(supplier: _buildSupplier()),
      );
      final receipts = <SupplierResult>[];
      vm.receipts.listen(receipts.add);

      await vm.getSupplier('CUST-1');
      await _pump();

      expect(receipts.single.customer, isNull);
    });

    test('prints without a customer when the customer lookup throws', () async {
      final vm = _buildViewModel(
        customerRepo: FakeCustomerRepository(
            throws: const NetworkException(message: 'offline')),
        supplierRepo: FakeSupplierRepository(supplier: _buildSupplier()),
      );
      final receipts = <SupplierResult>[];
      vm.receipts.listen(receipts.add);

      await vm.getSupplier('CUST-1');
      await _pump();

      expect(receipts, hasLength(1),
          reason: 'the name can still be typed into the dialog');
    });

    test('no shop profile yet sends the user to create one', () async {
      final vm = _buildViewModel(
        supplierRepo: FakeSupplierRepository(
            throws: const NotFoundException(message: 'no supplier')),
      );
      final setups = <void>[];
      final errors = <String>[];
      vm.supplierSetups.listen(setups.add);
      vm.errors.listen(errors.add);

      await vm.getSupplier('CUST-1');
      await _pump();

      expect(setups, hasLength(1));
      expect(errors, isEmpty, reason: 'nothing has gone wrong');
    });

    test('being offline is reported, not treated as a missing profile',
        () async {
      final vm = _buildViewModel(
        supplierRepo: FakeSupplierRepository(
            throws: const NetworkException(message: 'offline')),
      );
      final setups = <void>[];
      final errors = <String>[];
      vm.supplierSetups.listen(setups.add);
      vm.errors.listen(errors.add);

      await vm.getSupplier('CUST-1');
      await _pump();

      expect(errors, hasLength(1));
      expect(setups, isEmpty,
          reason: 'the old code opened the setup form, where the user found '
              'their profile already filled in and no explanation');
    });
  });

  test('a command is refused while another is in flight', () async {
    final repo = FakeOrderRepository(orderDetail: _buildOrderDetail('order-1'));
    final vm = _buildViewModel(orderRepo: repo);

    final first = vm.getOrderById('order-1');
    await vm.removeOrderById('order-1');
    await first;

    expect(repo.removedOrderIds, isEmpty,
        reason: 'a delete must not start while the document is still loading');
  });
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);
