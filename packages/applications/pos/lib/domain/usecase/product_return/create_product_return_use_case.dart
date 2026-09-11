// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class CreateProductReturnUseCase
    extends BaseUseCaseParam<CreateProductReturnParam, ProductReturn> {
  final ProductReturnRepository productReturnRepo;

  CreateProductReturnUseCase({required this.productReturnRepo});

  @override
  Future<ProductReturn> call(CreateProductReturnParam param) =>
      productReturnRepo.createProductReturn(param);
}
