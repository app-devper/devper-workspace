// Project imports:
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';

/// What a cashier changed on one Line, applied by the [Sale] in one step.
///
/// The line dialog edits a draft copy of the Line. Nothing reaches the Sale
/// until the cashier confirms, and then only this: the Sale decides what each
/// change means — a quantity of none takes the Line off, a batch reprices it,
/// a price the cashier picked becomes an Override.
class LineEdit {
  final int quantity;

  /// Per unit, in baht. A discount typed as a percentage arrives here already
  /// converted, and stays in baht if the Line is repriced later.
  final double discount;

  /// The price list the cashier picked by hand, or null if they did not.
  final String? overridePriceList;

  /// The batch the cashier picked, or null if they did not.
  final ProductStock? stock;

  const LineEdit({
    required this.quantity,
    required this.discount,
    this.overridePriceList,
    this.stock,
  });

  /// Reads what the cashier did to a draft.
  factory LineEdit.of(OrderItem draft) {
    return LineEdit(
      quantity: draft.quantity,
      discount: draft.discount,
      overridePriceList: draft.priceOverridden ? draft.customerType : null,
      stock: draft.chosenStock,
    );
  }
}
