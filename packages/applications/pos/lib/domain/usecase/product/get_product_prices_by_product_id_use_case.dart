// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetProductPricesByProductIdUseCase extends BaseUseCaseParam<String, List<ProductPrice>> {
  final ProductRepository productRepo;

  GetProductPricesByProductIdUseCase({required this.productRepo});

  @override
  Future<List<ProductPrice>> call(String productId) => productRepo.getProductPricesByProductId(productId);
}
