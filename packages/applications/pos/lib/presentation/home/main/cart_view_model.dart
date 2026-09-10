// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/usecase/order/create_order_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_use_case.dart';
import 'package:pos/presentation/home/main/cart_store.dart';
import 'cart_state.dart';

class CartViewModel {
  final CreateOrderUseCase createOrderUseCase;
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final UpdateProductStockUseCase updateProductStockUseCase;
  final CartStore cartStore;

  CartViewModel({
    required this.cartStore,
    required this.createOrderUseCase,
    required this.getProductByBarcodeUseCase,
    required this.updateProductStockUseCase,
  });

  final _state = ValueNotifier<CartState>(const CartState());

  ValueListenable<CartState> get state => _state;

  void prepareData() {
    selectCart(cartStore.cartIndex);
  }

  Future<void> addOrderItem(
      String serialNumber, List<OrderItem> orderItem) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final data = orderItem
          .where((item) => item.product.unit.barcode == serialNumber)
          .firstOrNull;
      if (data != null) {
        data.plusAmount();
      } else {
        final result = await getProductByBarcodeUseCase(serialNumber);
        if (result == null) {
          _state.value =
              _state.value.copyWith(loading: false, error: "ไม่พบสินค้า");
          return;
        }
        final productItems = result.toProductItems();
        final productItem = productItems
            .firstWhere((item) => item.unit.barcode == serialNumber);
        orderItem.add(OrderItem(
          product: productItem,
          quantity: 1,
          customerType: cartStore.customer?.type ?? priceTypeStock,
        ));
      }
      _emitOrderItems(orderItem);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> createOrder(CreateOrderParam param) async {
    // A second submit while one is in flight would bill the customer twice.
    if (_state.value.checkout is CheckoutSubmitting) return;
    _state.value = _state.value.copyWith(checkout: const CheckoutSubmitting());
    try {
      final result = await createOrderUseCase(param);
      for (var element in result.stocks) {
        await updateProductStockUseCase(element);
      }
      _state.value = _state.value.copyWith(checkout: CheckoutSucceeded(result));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(checkout: CheckoutFailed(toFailure(e)));
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

  void toggleAllowOversell(int index, List<OrderItem> orderItem) {
    orderItem[index].toggleAllowOversell();
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

  void editOrderItem(
      int index, OrderItem orderItem, List<OrderItem> orderItems) {
    orderItems[index] = orderItem;
    _emitOrderItems(orderItems);
  }

  void _emitOrderItems(List<OrderItem> orderItems) {
    _state.value = _state.value
        .copyWith(loading: false, orderItems: List<OrderItem>.of(orderItems));
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeOrderResult() {
    if (_state.value.checkout is CheckoutSucceeded) {
      _state.value = _state.value.copyWith(checkout: const CheckoutIdle());
    }
  }

  void consumeOrderError() {
    if (_state.value.checkout is CheckoutFailed) {
      _state.value = _state.value.copyWith(checkout: const CheckoutIdle());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
