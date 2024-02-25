// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';

abstract class ProductRepository {
  Future<String> generateSerialNumber();

  Future<Product> getProductBySerialNumber(String serialNumber);

  Future<Product> getProductById(String productId);

  Future<Product?> getLocalProductById(String productId);

  Future<Product> addProduct(ProductParam param);

  Future<Product> updateProductById(String productId, ProductParam param);

  Future<List<Product>> getProducts();

  Future<List<Product>> getLocalProducts();

  Future<Product> removeProductById(String productId);

  Future<List<ProductLot>> getProductLotsExpired();

  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param);

  Future<ProductLot> getProductLotByLotId(String lotId);

  Future<ProductLot> updateProductLotQuantityByLotId(String lotId, UpdateProductLotQuantityParam param);
}
