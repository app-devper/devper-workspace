// Project imports:
import 'package:pos/domain/model/product/product.dart';

class OrderItem {
  final Product product;
  int quantity = 1;
  double price = 0;

  OrderItem({
    required this.product,
    required this.quantity,
  }) {
    price = product.price;
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

  double amountPrice() {
    return quantity * price;
  }

  String getMessage() {
    return "ขาย ${product.name} จำนวน $quantity ${product.unit} ราคา ${amountPrice()} บาท";
  }
}
