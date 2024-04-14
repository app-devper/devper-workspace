// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';

abstract class ProductRepository {
  Future<String> generateSerialNumber();

  Future<Product?> getProductByBarcode(String barcode);

  Future<Product> getProductById(String productId);

  Future<Product?> getLocalProductById(String productId);

  Future<Product> addProductReceive(ProductParam param);

  Future<Product> addProduct(CreateProductParam param);

  Future<Product> updateProductById(String productId, ProductParam param);

  Future<List<Product>> getProducts();

  Future<List<Product>> getLocalProducts();

  Future<Product> removeProductById(String productId);

  Future<List<ProductLot>> getProductLotsExpired();

  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param);

  Future<ProductLot> getProductLotByLotId(String lotId);

  Future<ProductLot> updateProductLotQuantityByLotId(String lotId, UpdateProductLotQuantityParam param);


  Future<ProductPrice> addProductPrice(ProductPriceParam param);

  Future<ProductPrice> updateProductPriceById(String id, ProductPriceParam param);

  Future<ProductPrice> removeProductPriceById(String id);

  Future<List<ProductPrice>> getProductPricesByProductId(String productId);


  Future<ProductUnit> addProductUnit(ProductUnitParam param);

  Future<ProductUnit> updateProductUnitById(String id, ProductUnitParam param);

  Future<ProductUnit> removeProductUnitById(String id);

  Future<List<ProductUnit>> getProductUnitsByProductId(String productId);


  Future<ProductStock> addProductStock(ProductStockParam param);

  Future<ProductStock> updateProductStockById(String id, ProductStockParam param);

  Future<ProductStock> removeProductStockById(String id);

  Future<List<ProductStock>> getProductStocksByProductId(String productId);

  Future<ProductStock> updateProductStockQuantityById(String id, UpdateProductStockQuantityParam param);

  Future<List<ProductStock>> updateProductStockSequence(UpdateProductStockSequenceParam param);

  Future<void> updateProductStock(ProductStock element);

}
