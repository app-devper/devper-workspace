// Package imports:
import 'package:common/core/ext/date_ext.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';

class OrderItem {
  final ProductUnitItem product;

  /// Which price list this line was rung up at. It follows the sale's
  /// customer, unless the cashier has priced the line by hand.
  String customerType;

  /// The cashier chose this line's price themselves. A change of customer
  /// leaves it alone.
  bool priceOverridden = false;

  /// The batch the cashier rang this line up against, if they picked one.
  /// Allocation starts here; anything it cannot cover follows the Product's
  /// own sell-first order. Choosing one never changes that order.
  ProductStock? chosenStock;
  int quantity = 1;
  ProductPriceType priceType = ProductPriceType(
    stock: null,
    type: "",
    price: 0,
    costPrice: 0,
  );
  String unit = "";
  double discount = 0;
  bool allowOversell = false;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.customerType,
  }) {
    unit = product.unit.unit;
    priceType = _priceAt(customerType);
  }

  /// A separate Line with the same contents, for a caller to edit as a draft
  /// without touching the Sale it came from.
  OrderItem copy() {
    return OrderItem(
      product: product,
      quantity: quantity,
      customerType: customerType,
    )
      ..priceType = priceType
      ..unit = unit
      ..discount = discount
      ..allowOversell = allowOversell
      ..priceOverridden = priceOverridden
      ..chosenStock = chosenStock;
  }

  ProductPriceType _priceAt(String customerType) {
    final stock = chosenStock;
    return stock != null
        ? product.priceFrom(customerType, stock)
        : product.getPrice(customerType);
  }

  /// The cashier picked a price for this line by hand. It survives a change
  /// of customer.
  void overridePriceType(String customerType) {
    this.customerType = customerType;
    priceType = _priceAt(customerType);
    priceOverridden = true;
  }

  /// The sale's customer changed. A line priced by hand keeps that price; a
  /// discount is a separate negotiation and is never touched here.
  void repriceFor(String customerType) {
    if (priceOverridden) return;
    this.customerType = customerType;
    priceType = _priceAt(customerType);
  }

  /// Rings this line up against a particular batch.
  void chooseStock(ProductStock stock) {
    chosenStock = stock;
    priceType = _priceAt(customerType);
  }

  void updateDiscount(double discountPrice) {
    discount = discountPrice;
  }

  void updateDiscountByPercent(double percent) {
    discount = priceType.price * percent / 100;
  }

  void plusAmount() {
    quantity += 1;
  }

  void minusAmount() {
    if (quantity == 0) {
      return;
    }
    quantity -= 1;
  }

  void toggleAllowOversell() {
    allowOversell = !allowOversell;
  }

  double amountPriceWithDiscount() {
    return quantity * priceType.price - (discount * quantity);
  }

  double amountPrice() {
    return quantity * priceType.price;
  }

  double amountCostPrice() {
    return quantity * priceType.costPrice;
  }

  List<ProductStockOrder> getProductStockOrder() {
    List<ProductStockOrder> productStockOrder = [];
    final productStock = product.getProductStockById(priceType.stock?.id);
    if (productStock != null) {
      if (productStock.quantity >= quantity) {
        productStockOrder.add(ProductStockOrder(
          stockId: productStock.id,
          quantity: quantity,
        ));
      } else {
        productStockOrder.add(ProductStockOrder(
          stockId: productStock.id,
          quantity: productStock.quantity,
        ));
        final remainQuantity = quantity - productStock.quantity;
        findProductStockOrder(productStockOrder, remainQuantity);
      }
    } else {
      productStockOrder.add(
        ProductStockOrder(
          stockId: "",
          quantity: quantity,
        ),
      );
    }
    return productStockOrder;
  }

  List<ProductStockOrder> findProductStockOrder(
      List<ProductStockOrder> productStockOrder, int quantity) {
    final productStock = product.stocks
        .where((stock) =>
            stock.quantity > 0 &&
            productStockOrder.every((element) => element.stockId != stock.id))
        .firstOrNull;
    if (productStock != null) {
      if (productStock.quantity >= quantity) {
        productStockOrder.add(
          ProductStockOrder(
            stockId: productStock.id,
            quantity: quantity,
          ),
        );
      } else {
        productStockOrder.add(
          ProductStockOrder(
            stockId: productStock.id,
            quantity: productStock.quantity,
          ),
        );
        final remainQuantity = quantity - productStock.quantity;
        if (remainQuantity > 0) {
          findProductStockOrder(productStockOrder, remainQuantity);
        }
      }
    } else if (allowOversell &&
        productStockOrder.isNotEmpty &&
        productStockOrder.last.stockId.isNotEmpty) {
      // No stock left anywhere, but this line already touched a real lot: fold the
      // shortfall onto that lot so the backend's oversell/reconciliation path (keyed
      // off a non-empty stockId) applies, instead of silently routing it to the
      // unguarded "sold first" bucket (stockId "").
      final last = productStockOrder.removeLast();
      productStockOrder.add(
        ProductStockOrder(
          stockId: last.stockId,
          quantity: last.quantity + quantity,
        ),
      );
    } else {
      productStockOrder.add(
        ProductStockOrder(
          stockId: "",
          quantity: quantity,
        ),
      );
    }
    return productStockOrder;
  }

  String getPriceDetail() {
    switch (priceType.type) {
      case priceTypeStock:
        return "สต็อก${priceType.stock != null ? " ${priceType.stock!.importDate.formatDate()}" : ""}";
      case customerTypeGeneral:
        return "ราคาหน้าร้าน";
      case customerTypeRegular:
        return "ลูกค้าประจำ";
      case customerTypeWholesaler:
        return "ราคาขายส่ง";
      default:
        return "ไม่มีราคา";
    }
  }

  String getMessage() {
    return "ขาย ${product.name} จำนวน $quantity $unit ราคา ${amountPriceWithDiscount()} บาท";
  }

  void updateQuantity(double value) {
    quantity = value.toInt();
  }
}

class ProductStockOrder {
  final String stockId;
  final int quantity;

  ProductStockOrder({
    required this.stockId,
    required this.quantity,
  });
}
