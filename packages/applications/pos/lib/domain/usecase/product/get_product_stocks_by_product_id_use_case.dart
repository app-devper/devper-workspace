// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetProductStocksByProductIdUseCase extends BaseUseCaseParam<String, List<ProductStock>> {
  final ProductRepository productRepo;

  GetProductStocksByProductIdUseCase({required this.productRepo});

  @override
  Future<List<ProductStock>> call(String productId) => productRepo.getProductStocksByProductId(productId);
}
