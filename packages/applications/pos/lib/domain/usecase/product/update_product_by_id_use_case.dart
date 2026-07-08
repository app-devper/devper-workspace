// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductByIdUseCase extends BaseUseCaseParam<ProductUpdateParam, Product> {
  final ProductRepository productRepo;

  UpdateProductByIdUseCase({required this.productRepo});

  @override
  Future<Product> call(ProductUpdateParam param) => productRepo.updateProductById(param.productId, param.param);
}
