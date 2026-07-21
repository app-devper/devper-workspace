// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class RemoveProductStockByIdUseCase extends BaseUseCaseParam<String, ProductStock> {
  final ProductRepository productRepo;

  RemoveProductStockByIdUseCase({required this.productRepo});

  @override
  Future<ProductStock> call(String id) => productRepo.removeProductStockById(id);
}
