// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetLocalProductsUseCase extends BaseUseCase<List<Product>> {
  final ProductRepository productRepo;

  GetLocalProductsUseCase({required this.productRepo});

  @override
  Future<List<Product>> call() => productRepo.getLocalProducts();
}
