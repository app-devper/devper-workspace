// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ClearQuantitySoldFirstByIdUseCase extends BaseUseCaseParam<String, Product> {
  final ProductRepository productRepo;

  ClearQuantitySoldFirstByIdUseCase({required this.productRepo});

  @override
  Future<Product> call(String productId) => productRepo.clearQuantitySoldFirstById(productId);
}
