// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class GetProductByBarcodeUseCase extends BaseUseCaseParam<String, Product?> {
  final ProductRepository productRepo;

  GetProductByBarcodeUseCase({required this.productRepo});

  @override
  Future<Product?> call(String barcode) => productRepo.getProductByBarcode(barcode);
}
