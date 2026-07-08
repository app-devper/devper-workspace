// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class AddProductUnitUseCase extends BaseUseCaseParam<ProductUnitParam, ProductUnit> {
  final ProductRepository productRepo;

  AddProductUnitUseCase({required this.productRepo});

  @override
  Future<ProductUnit> call(ProductUnitParam param) => productRepo.addProductUnit(param);
}
