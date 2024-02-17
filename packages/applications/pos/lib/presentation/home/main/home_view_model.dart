// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'home_state.dart';

class HomeViewModel {
  final LoginRepository loginRepo;
  final OrderRepository orderRepo;
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;
  final CustomerRepository customerRepo;

  HomeViewModel({
    required this.loginRepo,
    required this.orderRepo,
    required this.productRepo,
    required this.categoryRepo,
    required this.customerRepo,
  });

  final _states = StreamController<HomeState>();

  Stream<HomeState> get states => _states.stream;

  List<Product> products = [];
  List<Customer> customers = [];

  void prepareData() async {
    getRole();
    getProducts();
  }

  void getRole() async {
    try {
      final result = await loginRepo.getRole();
      _onCheckLoginSuccess(result == "ADMIN");
    } on Exception catch (_) {
      _onCheckLoginSuccess(false);
    }
  }

  void getCacheCustomers() async {
    try {
      customers = await customerRepo.getLocalCustomers();
    } on Exception catch (_) {}
  }

  void getProducts() async {
    try {
      customers = await customerRepo.getLocalCustomers();
      products = await productRepo.getLocalProducts();
    } on Exception catch (_) {}
  }

  void logout() async {
    try {
      final result = await loginRepo.logoutUser();
      _onLogoutSuccess(result);
    } on Exception catch (_) {
      _onLogoutSuccess(true);
    }
  }

  void addOrderItem(String serialNumber, List<OrderItem> orderItem) async {
    _onLoading();
    try {
      final data = orderItem.where((item) => item.product.serialNumber == serialNumber).firstOrNull;
      if (data != null) {
        data.plusAmount();
      } else {
        final result = await productRepo.getProductBySerialNumber(serialNumber);
        orderItem.add(OrderItem(product: result, quantity: 1));
        final requireCustomer = await categoryRepo.requireCustomerOrder(result.category);
        if (requireCustomer) {
          _onRequireCustomer();
        }
      }
      _onOrderItemSuccess(orderItem);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void createOrder(CreateOrderParam param) async {
    _onOrderLoading();
    try {
      final result = await orderRepo.createOrder(param);
      _onOrderSuccess(result);
    } on Exception catch (e) {
      _onOrderError(toFailure(e));
    }
  }

  void plusItem(int index, List<OrderItem> orderItem) {
    final item = orderItem[index];
    item.plusAmount();
    orderItem[index] = item;
    _onOrderItemSuccess(orderItem);
  }

  void minusItem(int index, List<OrderItem> orderItem) {
    final item = orderItem[index];
    item.minusAmount();
    if (item.quantity == 0) {
      orderItem.removeAt(index);
    } else {
      orderItem[index] = item;
    }
    _onOrderItemSuccess(orderItem);
  }

  void removeItem(int index, List<OrderItem> orderItem) {
    orderItem.removeAt(index);
    _onOrderItemSuccess(orderItem);
  }

  void updatePriceItem(int index, int quantity, double price, List<OrderItem> orderItem) {
    final item = orderItem[index];
    item.quantity = quantity;
    item.price = price;
    orderItem[index] = item;
    _onOrderItemSuccess(orderItem);
  }

  void calculate(double price, double amount) {
    _onChangeSuccess(amount - price);
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onOrderItemSuccess(List<OrderItem> orderItem) {
    if (!_states.isClosed) {
      _states.sink.add(OrderItemState(orderItem));
    }
  }

  _onChangeSuccess(double change) {
    _states.sink.add(ChangeState(change));
  }

  _onOrderLoading() {
    _states.sink.add(OrderLoadingState());
  }

  _onOrderSuccess(Order order) {
    _states.sink.add(OrderState(order));
  }

  _onOrderError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(OrderErrorState(failure.getMessage()));
    }
  }

  _onCheckLoginSuccess(bool isLogin) {
    _states.sink.add((CheckRoleState(isLogin)));
  }

  _onCustomersSuccess(List<Customer> data) {
    if (!_states.isClosed) {
      _states.sink.add((CustomersState(data)));
    }
  }

  _onRequireCustomer() {
    if (!_states.isClosed) {
      _states.sink.add((RequireCustomerState()));
    }
  }

  _onLogoutSuccess(bool data) {
    _states.sink.add((LogoutState()));
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
