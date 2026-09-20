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

  /// The lines of the cart the cashier has open.
  ///
  /// Every edit goes through here. It used to be a parameter: the view held
  /// the copy published in state and handed it back to be edited, so the
  /// cart in the store was only ever read. Anything scanned was lost the
  /// moment the screen re-read it — on a cart switch, or on resume.
  List<OrderItem> get _lines => cartStore.cart[cartStore.cartIndex] ??= [];

  void prepareData() {
    selectCart(cartStore.cartIndex);
  }

  Future<void> addOrderItem(String serialNumber) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final lines = _lines;
      final data = lines
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
        lines.add(OrderItem(
          product: productItem,
          quantity: 1,
          customerType: cartStore.customer?.type ?? priceTypeStock,
        ));
      }
      _emitOrderItems();
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

  void plusItem(int index) {
    if (!_has(index)) return;
    _lines[index].plusAmount();
    _emitOrderItems();
  }

  void minusItem(int index) {
    if (!_has(index)) return;
    final lines = _lines;
    lines[index].minusAmount();
    if (lines[index].quantity == 0) {
      lines.removeAt(index);
    }
    _emitOrderItems();
  }

  void toggleAllowOversell(int index) {
    if (!_has(index)) return;
    _lines[index].toggleAllowOversell();
    _emitOrderItems();
  }

  void selectCart(int index) {
    cartStore.cartIndex = index;
    _emitOrderItems();
  }

  void clearCart() {
    cartStore.cart[cartStore.cartIndex] = [];
    cartStore.customer = null;
    _emitOrderItems();
  }

  void removeItem(int index) {
    if (!_has(index)) return;
    _lines.removeAt(index);
    _emitOrderItems();
  }

  void editItem(int index, String value) {
    if (!_has(index)) return;
    final lines = _lines;
    final quantity = value.isNotEmpty ? int.parse(value) : 0;
    if (quantity > 0) {
      lines[index].quantity = quantity;
    } else {
      lines.removeAt(index);
    }
    _emitOrderItems();
  }

  void editOrderItem(int index, OrderItem orderItem) {
    if (!_has(index)) return;
    _lines[index] = orderItem;
    _emitOrderItems();
  }

  /// A dialog can outlive the line it was opened on — the cart is editable
  /// behind it, and a barcode can arrive from the scanner at any moment.
  bool _has(int index) => index >= 0 && index < _lines.length;

  /// Publishes a copy, so the list the view renders is never the list the
  /// cart is holding.
  void _emitOrderItems() {
    _state.value = _state.value
        .copyWith(loading: false, orderItems: List<OrderItem>.of(_lines));
  }

  void dispose() {
    _state.dispose();
    _orderPlaced.dispose();
    _lookupErrors.dispose();
    _checkoutErrors.dispose();
  }
}
