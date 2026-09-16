// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/product_return_mapper.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class ProductReturnRepositoryImpl implements ProductReturnRepository {
  final PosService posService;

  /// The same catalogue cache ProductRepositoryImpl reads from. Returning
  /// stock changes quantities, so this write has to mark it stale — a fact
  /// about caching, which is why it lives here and not in a use case.
  final CachedList<Product> productCache;

  ProductReturnRepositoryImpl({
    required this.posService,
    required this.productCache,
  });

  @override
  Future<ProductReturn> createProductReturn(
      CreateProductReturnParam param) async {
    final response =
        await posService.createProductReturn(param.toProductReturnRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductReturnDomain();
    productCache.invalidate();
    return result;
  }

  @override
  Future<List<ProductReturn>> getProductReturnsByOrderId(String orderId) async {
    final response = await posService.getProductReturnsByOrderId(orderId);
    return (jsonOrThrow(response) as List).toProductReturnsDomain();
  }
}
