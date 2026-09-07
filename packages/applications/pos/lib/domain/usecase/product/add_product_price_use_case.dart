// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class AddProductPriceUseCase extends BaseUseCaseParam<ProductPriceParam, ProductPrice> {
  final ProductRepository productRepo;

  AddProductPriceUseCase({required this.productRepo});

  @override
  Future<ProductPrice> call(ProductPriceParam param) => productRepo.addProductPrice(param);
}
