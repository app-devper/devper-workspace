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
  static const _mapper = ProductMapper();

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
    final result = _mapper.toProductsDomain(jsonOrThrow(response));
    cache.fill(result);
    return cache.items;
  }

  @override
  Future<Product> getProductById(String productId) async {
    final response = await posService.getProductById(productId);
    return _mapper.toProductDomain(jsonOrThrow(response));
  }

  @override
  Future<Product> addProductReceive(ProductParam param) async {
    final request = _mapper.toProductRequest(param);
    final response = await posService.createProductReceive(request);
    return _mapper.toProductDomain(jsonOrThrow(response));
  }

  @override
  Future<Product> addProduct(CreateProductParam param) async {
    final request = _mapper.toCreateProductRequest(param);
    final response = await posService.createProduct(request);
    final product = _mapper.toProductDomain(jsonOrThrow(response));
    cache.items.add(product);
    return product;
  }

  @override
  Future<Product> updateProductById(
      String productId, ProductParam param) async {
    final request = _mapper.toUpdateProductRequest(param);
    final response = await posService.updateProductById(productId, request);
    final product = _mapper.toProductDomain(jsonOrThrow(response));
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
    final product = _mapper.toProductDomain(jsonOrThrow(response));
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
    return _mapper.toSerialNumberDomain(jsonOrThrow(response));
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
    return _mapper.toProductLotsDomain(data ?? []);
  }

  @override
  Future<ProductLot> getProductLotByLotId(String lotId) async {
    final response = await posService.getProductLotById(lotId);
    return _mapper.toProductLotDomain(jsonOrThrow(response));
  }

  @override
  Future<ProductLot> updateProductLotQuantityByLotId(
      String lotId, UpdateProductLotQuantityParam param) async {
    final request = _mapper.toUpdateProductLotQuantityRequest(param);
    final response =
        // Expiry notifications return product stock IDs, not legacy product lot IDs.
        await posService.updateProductStockQuantityById(lotId, request);
    return _mapper.toProductLotDomain(jsonOrThrow(response));
  }

  @override
  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param) async {
    final response =
        await posService.getProductLots(param.startDate, param.endDate);
    return _mapper.toProductLotsDomain(jsonOrThrow(response));
  }

  @override
  Future<ProductPrice> addProductPrice(ProductPriceParam param) async {
    final response =
        await posService.addProductPrice(_mapper.toProductPriceRequest(param));
    final price = _mapper.toProductPriceDomain(jsonOrThrow(response));
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
        id, _mapper.toProductPriceRequest(param));
    final price = _mapper.toProductPriceDomain(jsonOrThrow(response));
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
    final price = _mapper.toProductPriceDomain(jsonOrThrow(response));
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
    final prices = _mapper.toProductPricesDomain(jsonOrThrow(response));
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
        await posService.addProductUnit(_mapper.toProductUnitRequest(param));
    final unit = _mapper.toProductUnitDomain(jsonOrThrow(response));
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
        id, _mapper.toProductUnitRequest(param));
    final unit = _mapper.toProductUnitDomain(jsonOrThrow(response));
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
    final unit = _mapper.toProductUnitDomain(jsonOrThrow(response));
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
    final units = _mapper.toProductUnitsDomain(jsonOrThrow(response));
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
        await posService.addProductStock(_mapper.toProductStockRequest(param));
    final stock = _mapper.toProductStockDomain(jsonOrThrow(response));
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
        id, _mapper.toProductStockRequest(param));
    final stock = _mapper.toProductStockDomain(jsonOrThrow(response));
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
    final stock = _mapper.toProductStockDomain(jsonOrThrow(response));
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
    final stocks = _mapper.toProductStocksDomain(jsonOrThrow(response));
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
        id, _mapper.toUpdateProductStockQuantityRequest(param));
    final stock = _mapper.toProductStockDomain(jsonOrThrow(response));
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
        _mapper.toUpdateProductStockSequenceRequest(param));
    final stocks = _mapper.toProductStocksDomain(jsonOrThrow(response));
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
    final request = _mapper.toCreateProductLotRequest(param);
    final response = await posService.createProductLot(request);
    return _mapper.toProductLotDomain(jsonOrThrow(response));
  }

  @override
  Future<ProductLot> updateProductLotById(
      String lotId, UpdateProductLotParam param) async {
    final request = _mapper.toUpdateProductLotRequest(param);
    final response = await posService.updateProductLotById(lotId, request);
    return _mapper.toProductLotDomain(jsonOrThrow(response));
  }

  @override
  Future<ProductLot> deleteProductLotById(String lotId) async {
    final response = await posService.deleteProductLotById(lotId);
    return _mapper.toProductLotDomain(jsonOrThrow(response));
  }

  @override
  Future<List<ProductHistory>> getProductHistoriesByProductId(
      String productId) async {
    final response = await posService.getProductHistoriesByProductId(productId);
    return _mapper.toProductHistoriesDomain(jsonOrThrow(response));
  }

  @override
  Future<List<ProductHistory>> getProductHistoriesByDateRange(
      String startDate, String endDate) async {
    final response =
        await posService.getProductHistoriesByDateRange(startDate, endDate);
    return _mapper.toProductHistoriesDomain(jsonOrThrow(response));
  }

  @override
  Future<Product> clearQuantitySoldFirstById(String productId) async {
    final response = await posService.clearQuantitySoldFirstById(productId);
    final product = _mapper.toProductDomain(jsonOrThrow(response));
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
    final request = _mapper.toDrugInteractionCheckRequest(productIds);
    final response = await posService.checkDrugInteractions(request);
    final json = jsonOrThrow(response);
    return _mapper.toDrugInteractionResultsDomain(json['interactions'] ?? []);
  }

  @override
  Future<CSVImportResult> importProductCSV({
    required List<int> bytes,
    required String filename,
  }) async {
    final response =
        await posService.importProductCSV(bytes: bytes, filename: filename);
    return _mapper.toCSVImportResultDomain(jsonOrThrow(response));
  }
}
