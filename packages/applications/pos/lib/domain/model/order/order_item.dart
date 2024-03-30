// Package imports:
import 'package:common/core/ext/date_ext.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

class OrderItem {
  final ProductUnitItem product;
  final String customerType;
  int quantity = 1;
  ProductPriceType priceType = ProductPriceType(
    stock: null,
    type: "",
    price: 0,
    costPrice: 0,
  );
  String unit = "";
  double discount = 0;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.customerType,
  }) {
    unit = product.unit.unit;
    priceType = product.getPrice(customerType);
  }

  updatePriceType(String customerType) {
    priceType = product.getPrice(customerType);
  }

  updateDiscount(double discountPrice) {
    discount = discountPrice;
  }

  updateDiscountByPercent(double percent) {
    discount = priceType.price * percent / 100;
  }

  updateProductStockSequence(List<ProductStock> productStocks) {
    product.updateProductStockSequence(productStocks);
    priceType = product.getPrice(customerType);
  }

  plusAmount() {
    quantity += 1;
  }

  minusAmount() {
    if (quantity == 0) {
      return;
    }
    quantity -= 1;
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
    final productStock = product.getProductStockById(priceType.stock!.id);
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

  List<ProductStockOrder> findProductStockOrder(List<ProductStockOrder> productStockOrder, int quantity) {
    final productStock = product.stocks.where((stock) => stock.quantity > 0 && productStockOrder.every((element) => element.stockId != stock.id)).firstOrNull;
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
      case "Stock":
        return "สต็อก${priceType.stock != null ? " ${priceType.stock!.importDate.formatDate()}" : ""}";
      case "General":
        return "ราคาหน้าร้าน";
      case "Regular":
        return "ลูกค้าประจำ";
      case "Wholesaler":
        return "ราคาขายส่ง";
      default:
        return "ไม่มีราคา";
    }
  }

  String getMessage() {
    return "ขาย ${product.name} จำนวน $quantity $unit ราคา ${amountPrice()} บาท";
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
