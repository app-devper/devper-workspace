import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/usecase/order/get_order_range_use_case.dart';
import 'package:pos/presentation/order/main/order_ui_model.dart';
import 'package:pos/presentation/order/main/order_view_model.dart';
import 'package:um/domain/repositories/login_repository.dart';
import 'package:um/domain/usecase/auth/get_role_use_case.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderSummary> orders;
  final Object? error;
  GetOrderRangeParam? rangeParam;

  FakeOrderRepository({this.orders = const [], this.error});

  @override
  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param) async {
    if (error != null) throw error!;
    rangeParam = param;
    return orders;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeLoginRepository implements LoginRepository {
  final String role;
  final Object? error;

  FakeLoginRepository({this.role = 'USER', this.error});

  @override
  Future<String> getRole() async {
    if (error != null) throw error!;
    return role;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

OrderSummary buildOrder(
  String id, {
  required String type,
  required double total,
  required double totalCost,
}) {
  return OrderSummary(
    id: id,
    code: 'ORDER-$id',
    customerCode: 'C-1',
    customerName: 'Customer',
    createdDate: '2026-01-01T00:00:00.000Z',
    total: total,
    totalCost: totalCost,
    discount: 0,
    type: type,
  );
}

OrderViewModel buildViewModel({
  OrderRepository? orderRepository,
  LoginRepository? loginRepository,
}) {
  return OrderViewModel(
    getOrderRangeUseCase: GetOrderRangeUseCase(
      orderRepo: orderRepository ?? FakeOrderRepository(),
    ),
    getRoleUseCase: GetRoleUseCase(
      loginRepo: loginRepository ?? FakeLoginRepository(),
    ),
  );
}

GetOrderRangeParam buildRangeParam() {
  return GetOrderRangeParam(
    startDate: '2026-01-01',
    endDate: '2026-01-02',
  );
}

void main() {
  group('getOrderItem', () {
    final orders = [
      buildOrder('cash', type: 'Cash', total: 100, totalCost: 60),
      buildOrder('legacy', type: '', total: 50, totalCost: 30),
      buildOrder('online', type: 'Online', total: 200, totalCost: 120),
    ];

    test('filters Store orders and computes totals', () async {
      final repository = FakeOrderRepository(orders: orders);
      final vm = buildViewModel(orderRepository: repository);

      await vm.getOrderItem('Store', buildRangeParam());

      expect(vm.state.value.orders?.map((order) => order.id), [
        'cash',
        'legacy',
      ]);
      expect(vm.state.value.total, 150);
      expect(vm.state.value.totalCost, 90);
      expect(repository.rangeParam?.startDate, '2026-01-01');
    });

    test('filters Online orders and computes totals', () async {
      final vm = buildViewModel(
        orderRepository: FakeOrderRepository(orders: orders),
      );

      await vm.getOrderItem('Online', buildRangeParam());

      expect(vm.state.value.orders?.single.id, 'online');
      expect(vm.state.value.total, 200);
      expect(vm.state.value.totalCost, 120);
    });

    test('maps a typed exception to state.error', () async {
      final vm = buildViewModel(
        orderRepository: FakeOrderRepository(
          error: const NetworkException(message: 'offline'),
        ),
      );

      await vm.getOrderItem('Store', buildRangeParam());

      expect(vm.state.value.orders, isNull);
      expect(vm.state.value.error, isNotNull);

      vm.consumeError();
      expect(vm.state.value.error, isNull);
    });
  });

  group('role gate', () {
    test('checkLogin allows an admin', () async {
      final vm = buildViewModel(
        loginRepository: FakeLoginRepository(role: 'ADMIN'),
      );

      await vm.checkLogin();

      expect(vm.state.value.logged, isTrue);
      vm.consumeLogged();
      expect(vm.state.value.logged, isNull);
    });

    test('checkLogin maps a typed exception to state.error', () async {
      final vm = buildViewModel(
        loginRepository: FakeLoginRepository(
          error: const AuthException(message: 'expired'),
        ),
      );

      await vm.checkLogin();

      expect(vm.state.value.logged, isNull);
      expect(vm.state.value.error, isNotNull);
    });
  });

  group('range selection', () {
    test('initData exposes report ranges as a one-shot', () {
      final vm = buildViewModel();

      vm.initData();

      expect(vm.state.value.ranges, hasLength(6));
      expect(vm.state.value.initialized, isTrue);
      vm.consumeInitialized();
      expect(vm.state.value.initialized, isFalse);
    });

    test('today selects midnight through the next day', () {
      final vm = buildViewModel();
      final now = DateTime.now();

      vm.selectRange(Range.today);

      final selection = vm.state.value.rangeSelection!;
      expect(selection.range, Range.today);
      expect(selection.startDate, DateTime(now.year, now.month, now.day));
      expect(selection.endDate, DateTime(now.year, now.month, now.day + 1));

      vm.consumeRangeSelection();
      expect(vm.state.value.rangeSelection, isNull);
    });

    test('month does not emit a selection', () {
      final vm = buildViewModel();

      vm.selectRange(Range.month);

      expect(vm.state.value.rangeSelection, isNull);
    });
  });
}
