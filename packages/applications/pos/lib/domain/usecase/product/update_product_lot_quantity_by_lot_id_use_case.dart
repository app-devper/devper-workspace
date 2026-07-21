// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class UpdateProductLotQuantityByLotIdUseCase extends BaseUseCaseParam<ProductLotQuantityUpdateParam, ProductLot> {
  final ProductRepository productRepo;

  UpdateProductLotQuantityByLotIdUseCase({required this.productRepo});

  @override
  Future<ProductLot> call(ProductLotQuantityUpdateParam param) => productRepo.updateProductLotQuantityByLotId(param.lotId, param.param);
}
