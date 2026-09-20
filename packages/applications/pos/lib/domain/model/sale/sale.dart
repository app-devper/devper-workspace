// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';

/// One customer's purchase in progress at the till: its lines, its customer,
/// the prescription details that go on the record, and what it comes to.
///
/// This is the module the sales screen used not to have. The total was summed
/// in a 727-line widget, the order payload was assembled there too, and the
/// cart itself was four public mutable fields any widget could write. Nothing
/// about the money could be tested.
///
/// A Sale never reaches the network. The caller looks a barcode up and hands
/// the product over; everything the shop's rules decide — which price a line
/// charges, what a change of customer does to lines already scanned, whether
/// the money offered covers the sale — is decided here, and can be tested
/// without a single fake.
class Sale {
  final List<OrderItem> _lines = [];

  Customer? _customer;

  String? patientId;
  String? prescriberName;
  String? pharmacistName;

  /// The lines, for drawing. Editing them is the Sale's job, so the list the
  /// caller gets back cannot be edited.
  List<OrderItem> get lines => List.unmodifiable(_lines);

  bool get isEmpty => _lines.isEmpty;

  Customer? get customer => _customer;

  /// Which price list this sale charges at. Without a customer, a line sells
  /// at its stock's own price.
  String get priceList => _customer?.type ?? priceTypeStock;

  /// What the customer owes: every line at its price, less its discount.
  double get total {
    double amount = 0;
    for (final line in _lines) {
      amount += line.amountPriceWithDiscount();
    }
    return amount;
  }

  /// Whether the money offered settles the sale. Half a satang of floating
  /// point must not be the reason a cashier cannot close a till.
  bool covers(double tendered) => tendered - total > -0.005;

  /// The line already holding this barcode, if the sale has one.
  OrderItem? lineFor(String barcode) =>
      _lines.where((line) => line.product.unit.barcode == barcode).firstOrNull;

  /// Adds a product as a new line, priced for this sale's customer.
  void addLine(ProductUnitItem product) {
    _lines.add(OrderItem(
      product: product,
      quantity: 1,
      customerType: priceList,
    ));
  }

  void increase(int index) {
    if (!_has(index)) return;
    _lines[index].plusAmount();
  }

  /// Reducing the last one takes the line off the sale.
  void decrease(int index) {
    if (!_has(index)) return;
    _lines[index].minusAmount();
    if (_lines[index].quantity == 0) {
      _lines.removeAt(index);
    }
  }

  /// A quantity of none is a line the cashier is taking off.
  void setQuantity(int index, int quantity) {
    if (!_has(index)) return;
    if (quantity > 0) {
      _lines[index].quantity = quantity;
    } else {
      _lines.removeAt(index);
    }
  }

  void removeAt(int index) {
    if (!_has(index)) return;
    _lines.removeAt(index);
  }

  void toggleOversell(int index) {
    if (!_has(index)) return;
    _lines[index].toggleAllowOversell();
  }

  /// Puts back a line the cashier edited in the line dialog.
  void replaceLine(int index, OrderItem line) {
    if (!_has(index)) return;
    _lines[index] = line;
  }

  /// Changing who is buying reprices what is already scanned.
  ///
  /// A cashier who picked a price by hand meant it, so that line keeps it. A
  /// discount is a separate negotiation and is never touched.
  void setCustomer(Customer? customer) {
    _customer = customer;
    for (final line in _lines) {
      line.repriceFor(priceList);
    }
  }

  void setCompliance({
    String? patientId,
    String? prescriberName,
    String? pharmacistName,
  }) {
    this.patientId = patientId;
    this.prescriberName = prescriberName;
    this.pharmacistName = pharmacistName;
  }

  /// Empties the sale back to a fresh one: no lines, no customer, and none of
  /// the last customer's prescription details left on screen.
  void clear() {
    _lines.clear();
    _customer = null;
    patientId = null;
    prescriberName = null;
    pharmacistName = null;
  }

  /// The order to send.
  ///
  /// [tendered] is what the customer handed over, which is what the receipt
  /// records; it is not the total, because a customer may overpay and take
  /// change. Call [covers] before this.
  CreateOrderParam toOrder({required double tendered, required String type}) {
    return CreateOrderParam(
      customerCode: _customer?.code ?? "",
      customerName: _customer?.name ?? "",
      amount: tendered,
      items: List<OrderItem>.of(_lines),
      type: type,
      payments: [OrderPayment(amount: tendered, type: type)],
      patientId: _blankToNull(patientId),
      prescriberName: _blankToNull(prescriberName),
      pharmacistName: _blankToNull(pharmacistName),
    );
  }

  /// A dialog outlives the line it was opened on, and the scanner can fire
  /// while one is open.
  bool _has(int index) => index >= 0 && index < _lines.length;

  static String? _blankToNull(String? value) =>
      (value?.isNotEmpty ?? false) ? value : null;
}
