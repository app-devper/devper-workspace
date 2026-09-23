// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/sale/line_edit.dart';
import 'package:pos/domain/model/sale/sale.dart';
import 'package:pos/domain/model/sale/till.dart';
import 'package:pos/domain/usecase/order/create_order_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_use_case.dart';
import 'cart_state.dart';

class CartViewModel {
  final CreateOrderUseCase createOrderUseCase;
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final UpdateProductStockUseCase updateProductStockUseCase;
  final Till till;

  CartViewModel({
    required this.till,
    required this.createOrderUseCase,
    required this.getProductByBarcodeUseCase,
    required this.updateProductStockUseCase,
  });

  final _state = ValueNotifier<CartState>(const CartState());

  /// A finished order empties the sale and closes the payment sheet; the two
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

  Sale get _sale => till.open;

  int get openCart => till.openIndex;

  int get cartCount => till.size;

  bool cartHasLines(int index) => till.hasLines(index);

  Customer? get customer => _sale.customer;

  String? get patientId => _sale.patientId;

  String? get prescriberName => _sale.prescriberName;

  String? get pharmacistName => _sale.pharmacistName;

  void prepareData() {
    _publish();
  }

  /// Looks the barcode up and hands what came back to the sale.
  ///
  /// The lookup is the only part of a scan that leaves the device, which is
  /// why it lives here; what a scan does to the sale is the sale's business.
  Future<void> addOrderItem(String serialNumber) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      if (!_sale.increaseBarcode(serialNumber)) {
        final result = await getProductByBarcodeUseCase(serialNumber);
        if (result == null) {
          _state.value = _state.value.copyWith(loading: false);
          _lookupErrors.emit("ไม่พบสินค้า");
          return;
        }
        final productItem = result
            .toProductItems()
            .firstWhere((item) => item.unit.barcode == serialNumber);
        _sale.addLine(productItem);
      }
      _publish();
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _lookupErrors.emit(toFailure(e).getMessage());
    }
  }

  /// Takes payment. [tendered] is what the customer handed over, which may be
  /// more than the sale comes to.
  Future<void> checkout({
    required double tendered,
    required String type,
  }) async {
    // A second submit while one is in flight would bill the customer twice.
    if (_state.value.orderSaving) return;
    if (!_sale.covers(tendered)) {
      _checkoutErrors.emit("คุณรับเงินน้อยกว่ายอดราคาสินค้า");
      return;
    }
    _state.value = _state.value.copyWith(orderSaving: true);
    try {
      final result = await createOrderUseCase(
        _sale.toOrder(tendered: tendered, type: type),
      );
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
    _sale.increase(index);
    _publish();
  }

  void minusItem(int index) {
    _sale.decrease(index);
    _publish();
  }

  void toggleAllowOversell(int index) {
    _sale.toggleOversell(index);
    _publish();
  }

  void removeItem(int index) {
    _sale.removeAt(index);
    _publish();
  }

  void editItem(int index, String value) {
    _sale.setQuantity(index, value.isNotEmpty ? int.parse(value) : 0);
    _publish();
  }

  /// Applies what the cashier confirmed in the line dialog.
  void editLine(int index, LineEdit edit) {
    _sale.applyEdit(index, edit);
    _publish();
  }

  void selectCart(int index) {
    till.switchTo(index);
    _publish();
  }

  void setCustomer(Customer? customer) {
    _sale.setCustomer(customer);
    _publish();
  }

  void setCompliance({
    String? patientId,
    String? prescriberName,
    String? pharmacistName,
  }) {
    _sale.setCompliance(
      patientId: patientId,
      prescriberName: prescriberName,
      pharmacistName: pharmacistName,
    );
    _publish();
  }

  void clearCart() {
    _sale.clear();
    _publish();
  }

  /// Publishes what the screen draws. The lines go out as a copy, so a view
  /// that drops its copy does not drop the sale.
  void _publish() {
    _state.value = _state.value.copyWith(
      loading: false,
      orderItems: List<OrderItem>.of(_sale.lines),
      total: _sale.total,
    );
  }

  void dispose() {
    _state.dispose();
    _orderPlaced.dispose();
    _lookupErrors.dispose();
    _checkoutErrors.dispose();
  }
}
