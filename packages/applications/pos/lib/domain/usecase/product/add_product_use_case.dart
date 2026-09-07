// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class AddProductUseCase extends BaseUseCaseParam<CreateProductParam, Product> {
  final ProductRepository productRepo;

  AddProductUseCase({required this.productRepo});

  @override
  Future<Product> call(CreateProductParam param) => productRepo.addProduct(param);
}
