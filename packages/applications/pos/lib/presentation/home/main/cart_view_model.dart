// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/home/main/cart_store.dart';
import 'cart_state.dart';

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

  final _state = ValueNotifier<CartState>(const CartState());

  ValueListenable<CartState> get state => _state;

  void prepareData() {
    selectCart(cartStore.cartIndex);
  }

  Future<void> addOrderItem(String serialNumber, List<OrderItem> orderItem) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final data = orderItem.where((item) => item.product.unit.barcode == serialNumber).firstOrNull;
      if (data != null) {
        data.plusAmount();
      } else {
        final result = await productRepo.getProductByBarcode(serialNumber);
        if (result == null) {
          _state.value = _state.value.copyWith(loading: false, error: "ไม่พบสินค้า");
          return;
        }
        final productItems = result.toProductItems();
        final productItem = productItems.firstWhere((item) => item.unit.barcode == serialNumber);
        orderItem.add(OrderItem(
          product: productItem,
          quantity: 1,
          customerType: cartStore.customer?.type ?? priceTypeStock,
        ));
      }
      _emitOrderItems(orderItem);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> createOrder(CreateOrderParam param) async {
    _state.value = _state.value.copyWith(orderSaving: true, clearOrderError: true, clearOrderResult: true);
    try {
      final result = await orderRepo.createOrder(param);
      for (var element in result.stocks) {
        await productRepo.updateProductStock(element);
      }
      _state.value = _state.value.copyWith(orderSaving: false, orderResult: result);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(orderSaving: false, orderError: toFailure(e).getMessage());
    }
  }

  void plusItem(int index, List<OrderItem> orderItem) {
    final item = orderItem[index];
    item.plusAmount();
    orderItem[index] = item;
    _emitOrderItems(orderItem);
  }

  void minusItem(int index, List<OrderItem> orderItem) {
    final item = orderItem[index];
    item.minusAmount();
    if (item.quantity == 0) {
      orderItem.removeAt(index);
    } else {
      orderItem[index] = item;
    }
    _emitOrderItems(orderItem);
  }

  void selectCart(int index) {
    cartStore.cartIndex = index;
    if (cartStore.cart[index] == null) {
      cartStore.cart[index] = [];
    }
    _emitOrderItems(cartStore.cart[index]!);
  }

  void clearCart() {
    cartStore.cart[cartStore.cartIndex] = [];
    cartStore.customer = null;
    _emitOrderItems(cartStore.cart[cartStore.cartIndex]!);
  }

  void removeItem(int index, List<OrderItem> orderItem) {
    orderItem.removeAt(index);
    _emitOrderItems(orderItem);
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
    _emitOrderItems(orderItems);
  }

  void editOrderItem(int index, OrderItem orderItem, List<OrderItem> orderItems) {
    orderItems[index] = orderItem;
    _emitOrderItems(orderItems);
  }

  void _emitOrderItems(List<OrderItem> orderItems) {
    _state.value = _state.value.copyWith(loading: false, orderItems: List<OrderItem>.of(orderItems));
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeOrderResult() {
    if (_state.value.orderResult != null) {
      _state.value = _state.value.copyWith(clearOrderResult: true);
    }
  }

  void consumeOrderError() {
    if (_state.value.orderError != null) {
      _state.value = _state.value.copyWith(clearOrderError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
