// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class RemoveProductPriceByIdUseCase extends BaseUseCaseParam<String, ProductPrice> {
  final ProductRepository productRepo;

  RemoveProductPriceByIdUseCase({required this.productRepo});

  @override
  Future<ProductPrice> call(String id) => productRepo.removeProductPriceById(id);
}
