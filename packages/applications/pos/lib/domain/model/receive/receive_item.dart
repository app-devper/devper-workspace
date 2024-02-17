// Project imports:
import 'package:pos/domain/model/product/product.dart';

class ReceiveItem {
  final String id;
  final String productId;
  final String receiveId;
  final String lotId;
  final double costPrice;
  final int quantity;
  Product? product;

  ReceiveItem({
    required this.id,
    required this.receiveId,
    required this.productId,
    required this.lotId,
    required this.costPrice,
    required this.quantity,
    this.product
  });
}
