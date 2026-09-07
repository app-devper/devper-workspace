// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductStockSequenceUseCase extends BaseUseCaseParam<UpdateProductStockSequenceParam, List<ProductStock>> {
  final ProductRepository productRepo;

  UpdateProductStockSequenceUseCase({required this.productRepo});

  @override
  Future<List<ProductStock>> call(UpdateProductStockSequenceParam param) => productRepo.updateProductStockSequence(param);
}
