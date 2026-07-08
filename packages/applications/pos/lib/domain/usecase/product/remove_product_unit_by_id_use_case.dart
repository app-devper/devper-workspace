// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class RemoveProductUnitByIdUseCase extends BaseUseCaseParam<String, ProductUnit> {
  final ProductRepository productRepo;

  RemoveProductUnitByIdUseCase({required this.productRepo});

  @override
  Future<ProductUnit> call(String id) => productRepo.removeProductUnitById(id);
}
