// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductStockQuantityByIdUseCase extends BaseUseCaseParam<ProductStockQuantityUpdateParam, ProductStock> {
  final ProductRepository productRepo;

  UpdateProductStockQuantityByIdUseCase({required this.productRepo});

  @override
  Future<ProductStock> call(ProductStockQuantityUpdateParam param) => productRepo.updateProductStockQuantityById(param.id, param.param);
}
