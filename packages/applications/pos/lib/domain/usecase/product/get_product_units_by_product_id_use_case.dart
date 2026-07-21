// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetProductUnitsByProductIdUseCase extends BaseUseCaseParam<String, List<ProductUnit>> {
  final ProductRepository productRepo;

  GetProductUnitsByProductIdUseCase({required this.productRepo});

  @override
  Future<List<ProductUnit>> call(String productId) => productRepo.getProductUnitsByProductId(productId);
}
