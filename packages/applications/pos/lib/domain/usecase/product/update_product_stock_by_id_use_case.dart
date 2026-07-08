// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductStockByIdUseCase extends BaseUseCaseParam<ProductStockUpdateParam, ProductStock> {
  final ProductRepository productRepo;

  UpdateProductStockByIdUseCase({required this.productRepo});

  @override
  Future<ProductStock> call(ProductStockUpdateParam param) => productRepo.updateProductStockById(param.id, param.param);
}
