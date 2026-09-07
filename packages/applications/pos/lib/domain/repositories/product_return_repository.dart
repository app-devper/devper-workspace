// Project imports:
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';

abstract class ProductReturnRepository {
  Future<ProductReturn> createProductReturn(CreateProductReturnParam param);

  Future<List<ProductReturn>> getProductReturnsByOrderId(String orderId);
}
