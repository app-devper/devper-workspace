// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:pos/presentation/home/main/cart_store.dart';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'home_state.dart';

class CartViewModel {
  final OrderRepository orderRepo;
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;
  final CartStore cartStore;

  CartViewModel({
    required this.cartStore,
    required this.orderRepo,
    required this.productRepo,
    required this.categoryRepo,
  });

  final _states = StreamController<HomeState>();

  Stream<HomeState> get states => _states.stream;

  void prepareData() async {
    selectCart(cartStore.cartIndex);
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

  void selectCart(int index) {
    cartStore.cartIndex = index;
    if (cartStore.cart[index] == null) {
      cartStore.cart[index] = [];
    }
    _onOrderItemSuccess(cartStore.cart[index]!);
  }

  void clearCart() {
    cartStore.cart[cartStore.cartIndex] = [];
    cartStore.customer = null;
    _onOrderItemSuccess(cartStore.cart[cartStore.cartIndex]!);
  }

  void removeItem(int index, List<OrderItem> orderItem) {
    orderItem.removeAt(index);
    _onOrderItemSuccess(orderItem);
  }

  void editItem(int index, String value, List<OrderItem> orderItems) {
    final item = orderItems[index];
    final quantity = value.isNotEmpty ? int.parse(value) : 0;
    if (quantity > 0) {
      item.quantity = quantity;
      orderItems[index] = item;
    } else if (quantity <= 0) {
      orderItems.removeAt(index);
    }
    _onOrderItemSuccess(orderItems);
  }

  void updatePriceItem(int index, int quantity, double price, List<OrderItem> orderItem) {
    final item = orderItem[index];
    item.quantity = quantity;
    item.price = price;
    orderItem[index] = item;
    _onOrderItemSuccess(orderItem);
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onOrderItemSuccess(List<OrderItem> orderItem) {
    if (!_states.isClosed) {
      _states.sink.add(OrderItemState(orderItem));
    }
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

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
