// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductStockUseCase extends BaseUseCaseParam<ProductStock, void> {
  final ProductRepository productRepo;

  UpdateProductStockUseCase({required this.productRepo});

  @override
  Future<void> call(ProductStock param) => productRepo.updateProductStock(param);
}
