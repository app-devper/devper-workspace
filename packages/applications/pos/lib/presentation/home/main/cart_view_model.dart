// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order.dart';
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

  /// A finished order empties the cart and closes the payment sheet; the two
  /// failure channels stay separate because the screen treats them
  /// differently — one is a scan that found nothing, the other a sale that did
  /// not go through.
  final _orderPlaced = OneShot<OrderResult>();
  final _lookupErrors = OneShot<String>();
  final _checkoutErrors = OneShot<String>();

  ValueListenable<CartState> get state => _state;

  Stream<OrderResult> get orderPlaced => _orderPlaced.stream;

  Stream<String> get lookupErrors => _lookupErrors.stream;

  Stream<String> get checkoutErrors => _checkoutErrors.stream;

  void prepareData() {
    selectCart(cartStore.cartIndex);
  }

  Future<void> addOrderItem(
      String serialNumber, List<OrderItem> orderItem) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final data = orderItem
          .where((item) => item.product.unit.barcode == serialNumber)
          .firstOrNull;
      if (data != null) {
        data.plusAmount();
      } else {
        final result = await getProductByBarcodeUseCase(serialNumber);
        if (result == null) {
          _state.value = _state.value.copyWith(loading: false);
          _lookupErrors.emit("ไม่พบสินค้า");
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
      _state.value = _state.value.copyWith(loading: false);
      _lookupErrors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> createOrder(CreateOrderParam param) async {
    // A second submit while one is in flight would bill the customer twice.
    if (_state.value.orderSaving) return;
    _state.value = _state.value.copyWith(orderSaving: true);
    try {
      final result = await createOrderUseCase(param);
      for (var element in result.stocks) {
        await updateProductStockUseCase(element);
      }
      _orderPlaced.emit(result);
    } on Exception catch (e) {
      _checkoutErrors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(orderSaving: false);
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

  void dispose() {
    _state.dispose();
    _orderPlaced.dispose();
    _lookupErrors.dispose();
    _checkoutErrors.dispose();
  }
}
