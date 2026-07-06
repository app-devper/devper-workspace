// Dart imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
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

  // Product Lot
  Future<List<ProductLot>> getProductLotsExpired();

  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param);

  Future<ProductLot> getProductLotByLotId(String lotId);

  Future<ProductLot> createProductLot(CreateProductLotParam param);

  Future<ProductLot> updateProductLotById(
      String lotId, UpdateProductLotParam param);

  Future<ProductLot> deleteProductLotById(String lotId);

  Future<ProductLot> updateProductLotQuantityByLotId(
      String lotId, UpdateProductLotQuantityParam param);

  // Product Price
  Future<ProductPrice> addProductPrice(ProductPriceParam param);

  Future<ProductPrice> updateProductPriceById(
      String id, ProductPriceParam param);

  Future<ProductPrice> removeProductPriceById(String id);

  Future<List<ProductPrice>> getProductPricesByProductId(String productId);

  // Product Unit
  Future<ProductUnit> addProductUnit(ProductUnitParam param);

  Future<ProductUnit> updateProductUnitById(String id, ProductUnitParam param);

  Future<ProductUnit> removeProductUnitById(String id);

  Future<List<ProductUnit>> getProductUnitsByProductId(String productId);

  // Product Stock
  Future<ProductStock> addProductStock(ProductStockParam param);

  Future<ProductStock> updateProductStockById(
      String id, ProductStockParam param);

  Future<ProductStock> removeProductStockById(String id);

  Future<List<ProductStock>> getProductStocksByProductId(String productId);

  Future<ProductStock> updateProductStockQuantityById(
      String id, UpdateProductStockQuantityParam param);

  Future<List<ProductStock>> updateProductStockSequence(
      UpdateProductStockSequenceParam param);

  Future<void> updateProductStock(ProductStock element);

  // Product History
  Future<List<ProductHistory>> getProductHistoriesByProductId(String productId);

  Future<List<ProductHistory>> getProductHistoriesByDateRange(
      String startDate, String endDate);

  // Clear Sold-First
  Future<Product> clearQuantitySoldFirstById(String productId);

  // Drug Interaction
  Future<List<DrugInteractionResult>> checkDrugInteractions(
      List<String> productIds);

  // CSV Import
  Future<CSVImportResult> importProductCSV(http.MultipartFile file);
}
