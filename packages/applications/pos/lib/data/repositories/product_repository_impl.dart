// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/product_mapper.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final PosService posService;

  /// Shared with the repositories whose writes move stock — a return, for one —
  /// so they can mark the catalogue stale without the domain layer having to
  /// know a cache exists.
  final CachedList<Product> cache;

  ProductRepositoryImpl({
    required this.posService,
    required this.cache,
  });

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    // An empty cache is not an answer. Returning null here made a failed
    // inventory load read as "no such product" at the till, so fill it first
    // and let a network failure surface as one.
    if (cache.needsRefresh) await getProducts();
    return cache.items.where((product) {
      return product.status == productStatusActive &&
          product.units.any((unit) => unit.barcode == barcode);
    }).firstOrNull;
  }

  @override
  Future<List<Product>> getProducts() async {
    final response = await posService.getProducts();
    final result = (jsonOrThrow(response) as List).toProductsDomain();
    cache.fill(result);
    return cache.items;
  }

  @override
  Future<Product> getProductById(String productId) async {
    final response = await posService.getProductById(productId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductDomain();
  }

  @override
  Future<Product> addProductReceive(ProductParam param) async {
    final request = param.toProductRequest();
    final response = await posService.createProductReceive(request);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductDomain();
  }

  @override
  Future<Product> addProduct(CreateProductParam param) async {
    final request = param.toCreateProductRequest();
    final response = await posService.createProduct(request);
    final product =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductDomain();
    cache.items.add(product);
    return product;
  }

  @override
  Future<Product> updateProductById(
      String productId, ProductParam param) async {
    final request = param.toUpdateProductRequest();
    final response = await posService.updateProductById(productId, request);
    final product =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductDomain();
    for (var element in cache.items) {
      if (element.id == product.id) {
        element.name = product.name;
        element.nameEn = product.nameEn;
        element.description = product.description;
        element.price = product.price;
        element.costPrice = product.costPrice;
        element.unit = product.unit;
        element.quantity = product.quantity;
        element.soldFirst = product.soldFirst;
        element.serialNumber = product.serialNumber;
        element.category = product.category;
        element.minStock = product.minStock;
        element.drugInfo = product.drugInfo;
        element.drugRegistrations = product.drugRegistrations;
        element.createdDate = product.createdDate;
        element.status = product.status;
        break;
      }
    }
    return product;
  }

  @override
  Future<Product> removeProductById(String productId) async {
    final response = await posService.removeProductById(productId);
    final product =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductDomain();
    cache.items.removeWhere((element) => element.id == product.id);
    return product;
  }

  @override
  Future<List<Product>> getLocalProducts() {
    if (cache.needsRefresh) {
      return getProducts();
    }
    return Future.value(cache.items);
  }

  @override
  Future<String> generateSerialNumber() async {
    final response = await posService.generateSerialNumber();
    return (jsonOrThrow(response) as Map<String, dynamic>)
        .toSerialNumberDomain();
  }

  @override
  Future<Product?> getLocalProductById(String productId) async {
    if (cache.needsRefresh) await getProducts();
    return cache.items.where((item) => item.id == productId).firstOrNull;
  }

  @override
  Future<List<ProductLot>> getProductLotsExpired() async {
    final response = await posService.getProductLotsExpired();
    final json = jsonOrThrow(response);
    final data = json is Map<String, dynamic> ? json['data'] : json;
    return ((data ?? []) as List).toProductLotsDomain();
  }

  @override
  Future<ProductLot> getProductLotByLotId(String lotId) async {
    final response = await posService.getProductLotById(lotId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductLotDomain();
  }

  @override
  Future<ProductLot> updateProductLotQuantityByLotId(
      String lotId, UpdateProductLotQuantityParam param) async {
    final request = param.toUpdateProductLotQuantityRequest();
    final response =
        // Expiry notifications return product stock IDs, not legacy product lot IDs.
        await posService.updateProductStockQuantityById(lotId, request);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductLotDomain();
  }

  @override
  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param) async {
    final response =
        await posService.getProductLots(param.startDate, param.endDate);
    return (jsonOrThrow(response) as List).toProductLotsDomain();
  }

  @override
  Future<ProductPrice> addProductPrice(ProductPriceParam param) async {
    final response =
        await posService.addProductPrice(param.toProductPriceRequest());
    final price =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductPriceDomain();
    for (var element in cache.items) {
      if (element.id == price.productId) {
        element.prices.add(price);
        break;
      }
    }
    return price;
  }

  @override
  Future<ProductPrice> updateProductPriceById(
      String id, ProductPriceParam param) async {
    final response = await posService.updateProductPriceById(
        id, param.toProductPriceRequest());
    final price =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductPriceDomain();
    for (var element in cache.items) {
      if (element.id == price.productId) {
        for (var priceElement in element.prices) {
          if (priceElement.id == price.id) {
            priceElement.price = price.price;
            priceElement.customerType = price.customerType;
            break;
          }
        }
        break;
      }
    }
    return price;
  }

  @override
  Future<ProductPrice> removeProductPriceById(String id) async {
    final response = await posService.removeProductPriceById(id);
    final price =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductPriceDomain();
    for (var element in cache.items) {
      if (element.id == price.productId) {
        element.prices.removeWhere((element) => element.id == price.id);
        break;
      }
    }
    return price;
  }

  @override
  Future<List<ProductPrice>> getProductPricesByProductId(
      String productId) async {
    final response = await posService.getProductPricesByProductId(productId);
    final prices = (jsonOrThrow(response) as List).toProductPricesDomain();
    for (var element in cache.items) {
      if (element.id == productId) {
        element.prices = prices;
        break;
      }
    }
    return prices;
  }

  @override
  Future<ProductUnit> addProductUnit(ProductUnitParam param) async {
    final response =
        await posService.addProductUnit(param.toProductUnitRequest());
    final unit =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductUnitDomain();
    for (var element in cache.items) {
      if (element.id == unit.productId) {
        element.units.add(unit);
        break;
      }
    }
    return unit;
  }

  @override
  Future<ProductUnit> updateProductUnitById(
      String id, ProductUnitParam param) async {
    final response = await posService.updateProductUnitById(
        id, param.toProductUnitRequest());
    final unit =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductUnitDomain();
    for (var element in cache.items) {
      if (element.id == unit.productId) {
        for (var unitElement in element.units) {
          if (unitElement.id == unit.id) {
            unitElement.unit = unit.unit;
            unitElement.costPrice = unit.costPrice;
            unitElement.size = unit.size;
            unitElement.barcode = unit.barcode;
            unitElement.volume = unit.volume;
            unitElement.volumeUnit = unit.volumeUnit;
            break;
          }
        }
        break;
      }
    }
    return unit;
  }

  @override
  Future<ProductUnit> removeProductUnitById(String id) async {
    final response = await posService.removeProductUnitById(id);
    final unit =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductUnitDomain();
    for (var element in cache.items) {
      if (element.id == unit.productId) {
        element.units.removeWhere((element) => element.id == unit.id);
        break;
      }
    }
    return unit;
  }

  @override
  Future<List<ProductUnit>> getProductUnitsByProductId(String productId) async {
    final response = await posService.getProductUnitsByProductId(productId);
    final units = (jsonOrThrow(response) as List).toProductUnitsDomain();
    for (var element in cache.items) {
      if (element.id == productId) {
        element.units = units;
        break;
      }
    }
    return units;
  }

  @override
  Future<ProductStock> addProductStock(ProductStockParam param) async {
    final response =
        await posService.addProductStock(param.toProductStockRequest());
    final stock =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductStockDomain();
    for (var element in cache.items) {
      if (element.id == stock.productId) {
        element.stocks.add(stock);
        break;
      }
    }
    return stock;
  }

  @override
  Future<ProductStock> updateProductStockById(
      String id, ProductStockParam param) async {
    final response = await posService.updateProductStockById(
        id, param.toProductStockRequest());
    final stock =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductStockDomain();
    for (var element in cache.items) {
      if (element.id == stock.productId) {
        for (var stockElement in element.stocks) {
          if (stockElement.id == stock.id) {
            stockElement.quantity = stock.quantity;
            stockElement.costPrice = stock.costPrice;
            stockElement.price = stock.price;
            stockElement.expireDate = stock.expireDate;
            stockElement.importDate = stock.importDate;
            stockElement.lotNumber = stock.lotNumber;
            stockElement.sequence = stock.sequence;
            break;
          }
        }
        break;
      }
    }
    return stock;
  }

  @override
  Future<ProductStock> removeProductStockById(String id) async {
    final response = await posService.removeProductStockById(id);
    final stock =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductStockDomain();
    for (var element in cache.items) {
      if (element.id == stock.productId) {
        element.stocks.removeWhere((element) => element.id == stock.id);
        break;
      }
    }
    return stock;
  }

  @override
  Future<List<ProductStock>> getProductStocksByProductId(
      String productId) async {
    final response = await posService.getProductStocksByProductId(productId);
    final stocks = (jsonOrThrow(response) as List).toProductStocksDomain();
    for (var element in cache.items) {
      if (element.id == productId) {
        element.stocks = stocks;
        break;
      }
    }
    return stocks;
  }

  @override
  Future<ProductStock> updateProductStockQuantityById(
      String id, UpdateProductStockQuantityParam param) async {
    final response = await posService.updateProductStockQuantityById(
        id, param.toUpdateProductStockQuantityRequest());
    final stock =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductStockDomain();
    for (var element in cache.items) {
      if (element.id == stock.productId) {
        for (var stockElement in element.stocks) {
          if (stockElement.id == stock.id) {
            stockElement.quantity = stock.quantity;
            break;
          }
        }
        break;
      }
    }
    return stock;
  }

  @override
  Future<List<ProductStock>> updateProductStockSequence(
      UpdateProductStockSequenceParam param) async {
    final response = await posService.updateProductStockSequence(
        param.toUpdateProductStockSequenceRequest());
    final stocks = (jsonOrThrow(response) as List).toProductStocksDomain();
    for (var element in cache.items) {
      if (element.id == param.productId) {
        element.stocks = stocks;
        break;
      }
    }
    return stocks;
  }

  @override
  Future<void> updateProductStock(ProductStock stock) async {
    for (var product in cache.items) {
      if (product.id == stock.productId) {
        for (var stockElement in product.stocks) {
          if (stockElement.id == stock.id) {
            stockElement.quantity = stock.quantity;
            stockElement.costPrice = stock.costPrice;
            stockElement.price = stock.price;
            stockElement.expireDate = stock.expireDate;
            stockElement.importDate = stock.importDate;
            stockElement.lotNumber = stock.lotNumber;
            stockElement.sequence = stock.sequence;
            break;
          }
        }
        break;
      }
    }
  }

  @override
  Future<ProductLot> createProductLot(CreateProductLotParam param) async {
    final request = param.toCreateProductLotRequest();
    final response = await posService.createProductLot(request);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductLotDomain();
  }

  @override
  Future<ProductLot> updateProductLotById(
      String lotId, UpdateProductLotParam param) async {
    final request = param.toUpdateProductLotRequest();
    final response = await posService.updateProductLotById(lotId, request);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductLotDomain();
  }

  @override
  Future<ProductLot> deleteProductLotById(String lotId) async {
    final response = await posService.deleteProductLotById(lotId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toProductLotDomain();
  }

  @override
  Future<List<ProductHistory>> getProductHistoriesByProductId(
      String productId) async {
    final response = await posService.getProductHistoriesByProductId(productId);
    return (jsonOrThrow(response) as List).toProductHistoriesDomain();
  }

  @override
  Future<List<ProductHistory>> getProductHistoriesByDateRange(
      String startDate, String endDate) async {
    final response =
        await posService.getProductHistoriesByDateRange(startDate, endDate);
    return (jsonOrThrow(response) as List).toProductHistoriesDomain();
  }

  @override
  Future<Product> clearQuantitySoldFirstById(String productId) async {
    final response = await posService.clearQuantitySoldFirstById(productId);
    final product =
        (jsonOrThrow(response) as Map<String, dynamic>).toProductDomain();
    for (var element in cache.items) {
      if (element.id == product.id) {
        element.soldFirst = product.soldFirst;
        break;
      }
    }
    return product;
  }

  @override
  Future<List<DrugInteractionResult>> checkDrugInteractions(
      List<String> productIds) async {
    final request = productIds.toDrugInteractionCheckRequest();
    final response = await posService.checkDrugInteractions(request);
    final json = jsonOrThrow(response);
    return ((json['interactions'] ?? []) as List)
        .toDrugInteractionResultsDomain();
  }

  @override
  Future<CSVImportResult> importProductCSV({
    required List<int> bytes,
    required String filename,
  }) async {
    final response =
        await posService.importProductCSV(bytes: bytes, filename: filename);
    return (jsonOrThrow(response) as Map<String, dynamic>)
        .toCSVImportResultDomain();
  }
}
