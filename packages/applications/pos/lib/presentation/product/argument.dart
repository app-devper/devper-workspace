// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';

class ProductArgument {
  final Product product;

  ProductArgument(this.product);
}

class ProductAddArgument {
  final String? receiveId;

  ProductAddArgument(this.receiveId);
}

class ProductsArgument {
  final String mode;

  ProductsArgument(this.mode);
}


class ProductLotArgument {
  final ProductLot productLot;

  ProductLotArgument(this.productLot);
}
