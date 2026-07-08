// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetProductLotsUseCase extends BaseUseCaseParam<GetLotsRangeParam, List<ProductLot>> {
  final ProductRepository productRepo;

  GetProductLotsUseCase({required this.productRepo});

  @override
  Future<List<ProductLot>> call(GetLotsRangeParam param) => productRepo.getProductLots(param);
}
