// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetProductHistoriesByProductIdUseCase extends BaseUseCaseParam<String, List<ProductHistory>> {
  final ProductRepository productRepo;

  GetProductHistoriesByProductIdUseCase({required this.productRepo});

  @override
  Future<List<ProductHistory>> call(String productId) => productRepo.getProductHistoriesByProductId(productId);
}
