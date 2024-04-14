// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/exception.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/product_mapper.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final PosService posService;
  List<Product> _products = [];

  ProductRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    if (_products.isNotEmpty) {
      final result = _products.where((product) {
        return product.status == productStatusActive && product.units.any((unit) => unit.barcode == barcode);
      }).firstOrNull;
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  @override
  Future<List<Product>> getProducts() async {
    final mapper = ProductMapper();
    final response = await posService.getProducts();
    if (response.isSuccessful) {
      final result = mapper.toProductsDomain(jsonDecode(response.body));
      _products = result;
      return _products;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product> getProductById(String productId) async {
    final mapper = ProductMapper();
    final response = await posService.getProductById(productId);
    if (response.isSuccessful) {
      return mapper.toProductDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product> addProductReceive(ProductParam param) async {
    final mapper = ProductMapper();
    final request = mapper.toProductRequest(param);
    final response = await posService.createProductReceive(request);
    if (response.isSuccessful) {
      return mapper.toProductDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product> addProduct(CreateProductParam param) async {
    final mapper = ProductMapper();
    final request = mapper.toCreateProductRequest(param);
    final response = await posService.createProduct(request);
    if (response.isSuccessful) {
      final product = mapper.toProductDomain(jsonDecode(response.body));
      _products.add(product);
      return product;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product> updateProductById(String productId, ProductParam param) async {
    final mapper = ProductMapper();
    final request = mapper.toProductRequest(param);
    final response = await posService.updateProductById(productId, request);
    if (response.isSuccessful) {
      final product = mapper.toProductDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == product.id) {
          element.name = product.name;
          element.nameEn = product.nameEn;
          element.description = product.description;
          element.category = product.category;
          element.createdDate = product.createdDate;
          element.status = product.status;
          break;
        }
      }
      return product;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product> removeProductById(String productId) async {
    final mapper = ProductMapper();
    final response = await posService.removeProductById(productId);
    if (response.isSuccessful) {
      final product = mapper.toProductDomain(jsonDecode(response.body));
      _products.removeWhere((element) => element.id == product.id);
      return product;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<Product>> getLocalProducts() {
    if (_products.isEmpty) {
      return getProducts();
    } else {
      return Future.value(_products);
    }
  }

  @override
  Future<String> generateSerialNumber() async {
    final mapper = ProductMapper();
    final response = await posService.generateSerialNumber();
    if (response.isSuccessful) {
      return mapper.toSerialNumberDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product?> getLocalProductById(String productId) async {
    final product = _products.where((item) => item.id == productId).firstOrNull;
    if (product != null) {
      return Future.value(product);
    }
    return null;
  }

  @override
  Future<List<ProductLot>> getProductLotsExpired() async {
    final mapper = ProductMapper();
    final response = await posService.getProductLotsExpired();
    if (response.isSuccessful) {
      return mapper.toProductLotsDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductLot> getProductLotByLotId(String lotId) async {
    final mapper = ProductMapper();
    final response = await posService.getProductLotById(lotId);
    if (response.isSuccessful) {
      return mapper.toProductLotDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductLot> updateProductLotQuantityByLotId(String lotId, UpdateProductLotQuantityParam param) async {
    final mapper = ProductMapper();
    final request = mapper.toUpdateProductLotQuantityRequest(param);
    final response = await posService.updateProductLotQuantityById(lotId, request);
    if (response.isSuccessful) {
      return mapper.toProductLotDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param) async {
    final mapper = ProductMapper();
    final response = await posService.getProductLots(param.startDate, param.endDate);
    if (response.isSuccessful) {
      return mapper.toProductLotsDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductPrice> addProductPrice(ProductPriceParam param) async {
    final mapper = ProductMapper();
    final response = await posService.addProductPrice(mapper.toProductPriceRequest(param));
    if (response.isSuccessful) {
      final price = mapper.toProductPriceDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == price.productId) {
          element.prices.add(price);
          break;
        }
      }
      return price;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductPrice> updateProductPriceById(String id, ProductPriceParam param) async {
    final mapper = ProductMapper();
    final response = await posService.updateProductPriceById(id, mapper.toProductPriceRequest(param));
    if (response.isSuccessful) {
      final price = mapper.toProductPriceDomain(jsonDecode(response.body));
      for (var element in _products) {
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
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductPrice> removeProductPriceById(String id) async {
    final mapper = ProductMapper();
    final response = await posService.removeProductPriceById(id);
    if (response.isSuccessful) {
      final price = mapper.toProductPriceDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == price.productId) {
          element.prices.removeWhere((element) => element.id == price.id);
          break;
        }
      }
      return price;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<ProductPrice>> getProductPricesByProductId(String productId) async {
    final mapper = ProductMapper();
    final response = await posService.getProductPricesByProductId(productId);
    if (response.isSuccessful) {
      final prices = mapper.toProductPricesDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == productId) {
          element.prices = prices;
          break;
        }
      }
      return prices;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductUnit> addProductUnit(ProductUnitParam param) async {
    final mapper = ProductMapper();
    final response = await posService.addProductUnit(mapper.toProductUnitRequest(param));
    if (response.isSuccessful) {
      final unit = mapper.toProductUnitDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == unit.productId) {
          element.units.add(unit);
          break;
        }
      }
      return unit;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductUnit> updateProductUnitById(String id, ProductUnitParam param) async {
    final mapper = ProductMapper();
    final response = await posService.updateProductUnitById(id, mapper.toProductUnitRequest(param));
    if (response.isSuccessful) {
      final unit = mapper.toProductUnitDomain(jsonDecode(response.body));
      for (var element in _products) {
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
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductUnit> removeProductUnitById(String id) async {
    final mapper = ProductMapper();
    final response = await posService.removeProductUnitById(id);
    if (response.isSuccessful) {
      final unit = mapper.toProductUnitDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == unit.productId) {
          element.units.removeWhere((element) => element.id == unit.id);
          break;
        }
      }
      return unit;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<ProductUnit>> getProductUnitsByProductId(String productId) async {
    final mapper = ProductMapper();
    final response = await posService.getProductUnitsByProductId(productId);
    if (response.isSuccessful) {
      final units = mapper.toProductUnitsDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == productId) {
          element.units = units;
          break;
        }
      }
      return units;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductStock> addProductStock(ProductStockParam param) async {
    final mapper = ProductMapper();
    final response = await posService.addProductStock(mapper.toProductStockRequest(param));
    if (response.isSuccessful) {
      final stock = mapper.toProductStockDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == stock.productId) {
          element.stocks.add(stock);
          break;
        }
      }
      return stock;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductStock> updateProductStockById(String id, ProductStockParam param) async {
    final mapper = ProductMapper();
    final response = await posService.updateProductStockById(id, mapper.toProductStockRequest(param));
    if (response.isSuccessful) {
      final stock = mapper.toProductStockDomain(jsonDecode(response.body));
      for (var element in _products) {
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
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductStock> removeProductStockById(String id) async {
    final mapper = ProductMapper();
    final response = await posService.removeProductStockById(id);
    if (response.isSuccessful) {
      final stock = mapper.toProductStockDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == stock.productId) {
          element.stocks.removeWhere((element) => element.id == stock.id);
          break;
        }
      }
      return stock;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<ProductStock>> getProductStocksByProductId(String productId) async {
    final mapper = ProductMapper();
    final response = await posService.getProductStocksByProductId(productId);
    if (response.isSuccessful) {
      final stocks = mapper.toProductStocksDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == productId) {
          element.stocks = stocks;
          break;
        }
      }
      return stocks;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<ProductStock> updateProductStockQuantityById(String id, UpdateProductStockQuantityParam param) async {
    final mapper = ProductMapper();
    final response = await posService.updateProductStockQuantityById(id, mapper.toUpdateProductStockQuantityRequest(param));
    if (response.isSuccessful) {
      final stock = mapper.toProductStockDomain(jsonDecode(response.body));
      for (var element in _products) {
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
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<ProductStock>> updateProductStockSequence(UpdateProductStockSequenceParam param) async {
    final mapper = ProductMapper();
    final response = await posService.updateProductStockSequence(mapper.toUpdateProductStockSequenceRequest(param));
    if (response.isSuccessful) {
      final stocks = mapper.toProductStocksDomain(jsonDecode(response.body));
      for (var element in _products) {
        if (element.id == param.productId) {
          element.stocks = stocks;
          break;
        }
      }
      return stocks;
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<void> updateProductStock(ProductStock stock) async {
    for (var product in _products) {
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
}
