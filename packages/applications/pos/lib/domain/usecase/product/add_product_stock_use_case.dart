// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class AddProductStockUseCase extends BaseUseCaseParam<ProductStockParam, ProductStock> {
  final ProductRepository productRepo;

  AddProductStockUseCase({required this.productRepo});

  @override
  Future<ProductStock> call(ProductStockParam param) => productRepo.addProductStock(param);
}
