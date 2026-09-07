// Project imports:
import 'package:pos/domain/model/product/product.dart';

class ReceiveItem {
  final String id;
  final String productId;
  final String receiveId;
  final String lotId;
  final double costPrice;
  final int quantity;
  final String lotNumber;
  final String expireDate;
  final String unitId;
  final int baseQuantity;
  Product? product;

  ReceiveItem(
      {this.id = '',
      required this.receiveId,
      required this.productId,
      this.lotId = '',
      this.lotNumber = '',
      this.expireDate = '',
      this.unitId = '',
      this.baseQuantity = 0,
      required this.costPrice,
      required this.quantity,
      this.product});
}
