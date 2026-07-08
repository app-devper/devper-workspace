// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductUnitByIdUseCase extends BaseUseCaseParam<ProductUnitUpdateParam, ProductUnit> {
  final ProductRepository productRepo;

  UpdateProductUnitByIdUseCase({required this.productRepo});

  @override
  Future<ProductUnit> call(ProductUnitUpdateParam param) => productRepo.updateProductUnitById(param.id, param.param);
}
