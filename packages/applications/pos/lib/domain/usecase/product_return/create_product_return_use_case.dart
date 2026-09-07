import 'package:pos/domain/repositories/product_repository.dart';
// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class CreateProductReturnUseCase extends BaseUseCaseParam<CreateProductReturnParam, ProductReturn> {
  final ProductRepository productRepo;
  final ProductReturnRepository productReturnRepo;

  CreateProductReturnUseCase({required this.productReturnRepo, required this.productRepo});

  @override
  Future<ProductReturn> call(CreateProductReturnParam param) async {
    final result = await productReturnRepo.createProductReturn(param);
    productRepo.invalidateProductsCache();
    return result;
  }
}
