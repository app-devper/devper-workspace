// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

class ProductLot {
  final String id;
  final String productId;
  final String lotNumber;
  final double costPrice;
  final int quantity;
  final String expireDate;
  final bool notify;
  Product? product;

  ProductLot({
    required this.id,
    required this.productId,
    required this.lotNumber,
    required this.costPrice,
    required this.quantity,
    required this.expireDate,
    required this.notify,
    this.product,
  });

  String getExpireDate() {
    final date = DateTime.parse(expireDate);
    final format = DateFormat("dd/MM/yyyy");
    return format.format(date.toLocal());
  }
}
