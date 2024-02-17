// Project imports:
import 'package:pos/domain/model/product/product.dart';

class OrderArgument {
  final String orderId;

  OrderArgument(this.orderId);
}

class OrderHistoryArgument {
  final Product product;

  OrderHistoryArgument(this.product);
}
