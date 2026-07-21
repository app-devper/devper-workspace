// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class GetProductReturnsByOrderIdUseCase extends BaseUseCaseParam<String, List<ProductReturn>> {
  final ProductReturnRepository productReturnRepo;

  GetProductReturnsByOrderIdUseCase({required this.productReturnRepo});

  @override
  Future<List<ProductReturn>> call(String orderId) => productReturnRepo.getProductReturnsByOrderId(orderId);
}
