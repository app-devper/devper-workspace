import 'package:common/core/usecase/usecase.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

/// Reload the product cache after inventory changes, including receive import.
class GetProductsUseCase extends BaseUseCase<List<Product>> {
  final ProductRepository productRepo;
  GetProductsUseCase({required this.productRepo});

  @override
  Future<List<Product>> call() => productRepo.getProducts();
}
