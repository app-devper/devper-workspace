import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/usecase/order/get_order_range_use_case.dart';
import 'package:pos/presentation/order/main/order_ui_model.dart';
import 'package:pos/presentation/order/main/order_view_model.dart';
import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart' as um;
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/repositories/login_repository.dart';

OrderSummary order(String id, String type, {double total = 100, double cost = 60}) {
  return OrderSummary(
    id: id,
    code: 'OD-$id',
    customerCode: 'C1',
    customerName: 'ลูกค้า',
    createdDate: '2026-09-01T00:00:00Z',
    total: total,
    totalCost: cost,
    discount: 0,
    type: type,
  );
}

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({this.orders = const [], this.throws});

  final List<OrderSummary> orders;
  Object? throws;

  @override
  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param) async {
    final error = throws;
    if (error != null) throw error;
    return orders;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeLoginRepository implements LoginRepository {
  FakeLoginRepository({this.role = 'USER', this.throws});

  final String role;
  final Object? throws;

  @override
  Future<String> getRole() async {
    final error = throws;
    if (error != null) throw error;
    return role;
  }

  @override
  Future<Session> loginUser(LoginParam param) => throw UnimplementedError();

  @override
  Future<Login> keepAlive() => throw UnimplementedError();

  @override
  Future<bool> logoutUser() => throw UnimplementedError();

  @override
  Future<um.System> getSystem() => throw UnimplementedError();

  @override
  String getClientId() => 'C1';

  @override
  Future<List<UserSession>> getSessions() => throw UnimplementedError();

  @override
  Future<bool> revokeSessionById(String sessionId) => throw UnimplementedError();

  @override
  Future<int> revokeOtherSessions() => throw UnimplementedError();
}

OrderViewModel buildViewModel({
  FakeOrderRepository? orders,
  FakeLoginRepository? login,
}) {
  return OrderViewModel(
    getOrderRangeUseCase:
        GetOrderRangeUseCase(orderRepo: orders ?? FakeOrderRepository()),
    loginRepo: login ?? FakeLoginRepository(),
  );
}

GetOrderRangeParam anyRange() =>
    GetOrderRangeParam(startDate: '2026-09-01', endDate: '2026-09-02');

void main() {
  group('filtering by channel', () {
    final mixed = [
      order('1', 'Cash'),
      order('2', 'Online'),
      order('3', ''),
      order('4', 'Cash'),
    ];

    test('Store covers cash sales and the ones with no channel recorded',
        () async {
      final viewModel = buildViewModel(orders: FakeOrderRepository(orders: mixed));

      await viewModel.getOrderItem('Store', anyRange());

      // An order saved before the channel existed has an empty type; it was
      // rung up at the counter, so it belongs with the store sales.
      expect(viewModel.state.value.orders!.map((e) => e.id), ['1', '3', '4']);
    });

    test('Online covers only the online channel', () async {
      final viewModel = buildViewModel(orders: FakeOrderRepository(orders: mixed));

      await viewModel.getOrderItem('Online', anyRange());

      expect(viewModel.state.value.orders!.map((e) => e.id), ['2']);
    });

    test('any other type keeps every order', () async {
      final viewModel = buildViewModel(orders: FakeOrderRepository(orders: mixed));

      await viewModel.getOrderItem('All', anyRange());

      expect(viewModel.state.value.orders, hasLength(4));
    });
  });

  test('the totals count the filtered orders, not everything fetched',
      () async {
    final viewModel = buildViewModel(
      orders: FakeOrderRepository(orders: [
        order('1', 'Cash', total: 100, cost: 60),
        order('2', 'Online', total: 999, cost: 999),
        order('3', '', total: 50, cost: 20),
      ]),
    );

    await viewModel.getOrderItem('Store', anyRange());

    expect(viewModel.state.value.total, 150);
    expect(viewModel.state.value.totalCost, 80);
  });

  test('a failed refresh reports the error and keeps what is on screen',
      () async {
    final repo = FakeOrderRepository(orders: [order('1', 'Cash')]);
    final viewModel = buildViewModel(orders: repo);

    await viewModel.getOrderItem('Store', anyRange());
    expect(viewModel.state.value.orders, hasLength(1));

    repo.throws = const NetworkException(message: 'down', code: 'NETWORK_ERROR');
    await viewModel.getOrderItem('Store', anyRange());

    expect(viewModel.state.value.error, contains('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้'));
    // The list a cashier was reading stays put; a dropped connection should
    // not blank the screen.
    expect(viewModel.state.value.orders, hasLength(1));

    viewModel.consumeError();
    expect(viewModel.state.value.error, isNull);
  });

  group('checkLogin', () {
    test('only ADMIN counts as logged for this screen', () async {
      final admin = buildViewModel(login: FakeLoginRepository(role: 'ADMIN'));
      final cashier = buildViewModel(login: FakeLoginRepository(role: 'USER'));

      await admin.checkLogin();
      await cashier.checkLogin();

      expect(admin.state.value.logged, isTrue);
      expect(cashier.state.value.logged, isFalse);
    });

    test('an unreadable role surfaces as an error', () async {
      final viewModel = buildViewModel(
        login: FakeLoginRepository(
          throws: const AuthException(message: 'expired', code: 'AU-401'),
        ),
      );

      await viewModel.checkLogin();

      expect(viewModel.state.value.error, isNotNull);
    });
  });

  group('date ranges', () {
    DateTime midnight() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    test('today spans midnight to midnight', () {
      final viewModel = buildViewModel();

      viewModel.selectRange(Range.today);

      final selection = viewModel.state.value.rangeSelection!;
      expect(selection.startDate, midnight());
      expect(selection.endDate, midnight().add(const Duration(days: 1)));
    });

    test('yesterday ends where today begins', () {
      final viewModel = buildViewModel();

      viewModel.selectRange(Range.yesterday);

      final selection = viewModel.state.value.rangeSelection!;
      expect(selection.startDate, midnight().subtract(const Duration(days: 1)));
      expect(selection.endDate, midnight());
    });

    test('current month runs from the first to the first of the next', () {
      final viewModel = buildViewModel();
      final now = DateTime.now();

      viewModel.selectRange(Range.currentMonth);

      final selection = viewModel.state.value.rangeSelection!;
      expect(selection.startDate, DateTime(now.year, now.month, 1));
      expect(selection.endDate, DateTime(now.year, now.month + 1, 1));
    });

    test('last month ends where the current one begins', () {
      final viewModel = buildViewModel();
      final now = DateTime.now();

      viewModel.selectRange(Range.lastMonth);

      final selection = viewModel.state.value.rangeSelection!;
      expect(selection.startDate, DateTime(now.year, now.month - 1, 1));
      expect(selection.endDate, DateTime(now.year, now.month, 1));
    });
  });

  test('initData offers the ranges the screen can pick from', () {
    final viewModel = buildViewModel();

    viewModel.initData();

    expect(viewModel.state.value.ranges, hasLength(6));
    expect(viewModel.state.value.initialized, isTrue);

    viewModel.consumeInitialized();
    expect(viewModel.state.value.initialized, isFalse);
  });
}
