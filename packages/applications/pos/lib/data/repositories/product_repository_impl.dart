// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/exception.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/product_mapper.dart';
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
  Future<Product> getProductBySerialNumber(String serialNumber) async {
    if (_products.isNotEmpty) {
      final result = _products.where((element) => element.serialNumber == serialNumber).firstOrNull;
      if (result != null) {
        return result;
      }
    }
    final mapper = ProductMapper();
    final response = await posService.getProductBySerialNumber(serialNumber);
    if (response.isSuccessful) {
      return mapper.toProductDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
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
  Future<Product> addProduct(ProductParam param) async {
    final mapper = ProductMapper();
    final request = mapper.toProductRequest(param);
    final response = await posService.createProduct(request);
    if (response.isSuccessful) {
      return mapper.toProductDomain(jsonDecode(response.body));
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
      return mapper.toProductDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<Product> removeProductById(String productId) async {
    final mapper = ProductMapper();
    final response = await posService.removeProductById(productId);
    if (response.isSuccessful) {
      return mapper.toProductDomain(jsonDecode(response.body));
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
}
