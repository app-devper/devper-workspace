// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductPriceByIdUseCase extends BaseUseCaseParam<ProductPriceUpdateParam, ProductPrice> {
  final ProductRepository productRepo;

  UpdateProductPriceByIdUseCase({required this.productRepo});

  @override
  Future<ProductPrice> call(ProductPriceUpdateParam param) => productRepo.updateProductPriceById(param.id, param.param);
}
