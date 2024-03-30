// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';

class ProductMapper {
  List<Product> toProductsDomain(List json) {
    final products = json.map((data) => toProductDomain(data)).toList();
    return products;
  }

  Product toProductDomain(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      description: json['description'],
      createdDate: json['createdDate'],
      category: json['category'],
      units: toProductUnitsDomain(json['units'] ?? []),
      prices: toProductPricesDomain(json['prices'] ?? []),
      stocks: toProductStocksDomain(json['stocks'] ?? []),
    );
  }

  List<ProductUnit> toProductUnitsDomain(List json) {
    final units = json.map((data) => toProductUnitDomain(data)).toList();
    return units;
  }

  ProductUnit toProductUnitDomain(Map<String, dynamic> json) {
    return ProductUnit(
      id: json['id'],
      productId: json['productId'],
      unit: json['unit'],
      costPrice: json['costPrice'].toDouble(),
      size: json['size'],
      barcode: json['barcode'],
      volume: json['volume'].toDouble(),
      volumeUnit: json['volumeUnit'],
    );
  }

  ProductPrice toProductPriceDomain(Map<String, dynamic> json) {
    return ProductPrice(
      id: json['id'],
      productId: json['productId'],
      unitId: json['unitId'],
      customerType: json['customerType'],
      price: json['price'].toDouble(),
    );
  }

  List<ProductPrice> toProductPricesDomain(List json) {
    final prices = json.map((data) => toProductPriceDomain(data)).toList();
    return prices;
  }

  List<ProductStock> toProductStocksDomain(List json) {
    final stocks = json.map((data) => toProductStockDomain(data)).toList();
    return stocks;
  }

  ProductStock toProductStockDomain(Map<String, dynamic> json) {
    return ProductStock(
      id: json['id'],
      unitId: json['unitId'],
      productId: json['productId'],
      receiveCode: json['receiveCode'],
      sequence: json['sequence'],
      lotNumber: json['lotNumber'],
      costPrice: json['costPrice'].toDouble(),
      price: json['price'].toDouble(),
      import: json['import'],
      quantity: json['quantity'],
      expireDate: json['expireDate'],
      importDate: json['importDate'],
    );
  }

  List<ProductLot> toProductLotsDomain(List json) {
    final lots = json.map((data) => toProductLotDomain(data)).toList();
    return lots;
  }

  ProductLot toProductLotDomain(Map<String, dynamic> json) {
    return ProductLot(
      id: json['id'],
      costPrice: json['costPrice'].toDouble(),
      quantity: json['quantity'],
      productId: json['productId'],
      lotNumber: json['lotNumber'],
      expireDate: json['expireDate'],
      notify: json['notify'],
    );
  }

  String toSerialNumberDomain(Map<String, dynamic> json) {
    return json['serialNumber'];
  }

  String toProductRequest(ProductParam param) {
    return jsonEncode({
      'name': param.name,
      'nameEn': param.nameEn,
      'description': param.description,
      'price': param.price,
      'costPrice': param.costPrice,
      'quantity': param.quantity,
      'unit': param.unit,
      'serialNumber': param.serialNumber,
      'lotNumber': param.lotNumber,
      'category': param.category,
      'expireDate': param.expireDate,
      'receiveId': param.receiveId,
    });
  }

  String toUpdateProductLotQuantityRequest(UpdateProductLotQuantityParam param) {
    return jsonEncode({
      'quantity': param.quantity,
    });
  }

  String toProductPriceRequest(ProductPriceParam param) {
    return jsonEncode({
      'productId': param.productId,
      'unitId': param.unitId,
      'customerType': param.customerType,
      'price': param.price,
    });
  }

  String toProductUnitRequest(ProductUnitParam param) {
    return jsonEncode({
      'productId': param.productId,
      'unit': param.unit,
      'costPrice': param.costPrice,
      'size': param.size,
      'barcode': param.barcode,
      'volume': param.volume,
      'volumeUnit': param.volumeUnit,
    });
  }

  String toProductStockRequest(ProductStockParam param) {
    return jsonEncode({
      'unitId': param.unitId,
      'productId': param.productId,
      'lotNumber': param.lotNumber,
      'costPrice': param.costPrice,
      'price': param.price,
      'quantity': param.quantity,
      'expireDate': param.expireDate,
      'importDate': param.importDate,
    });
  }

  String toUpdateProductStockQuantityRequest(UpdateProductStockQuantityParam param) {
    return jsonEncode({
      'quantity': param.quantity,
    });
  }

  String toUpdateProductStockSequenceRequest(UpdateProductStockSequenceParam param) {
    return jsonEncode({
      'stocks': param.stocks
          .map((stock) => {
                'stockId': stock.stockId,
                'sequence': stock.sequence,
              })
          .toList(),
    });
  }

  toCreateProductRequest(CreateProductParam param) {
    return jsonEncode({
      'name': param.name,
      'nameEn': param.nameEn,
      'description': param.description,
      'category': param.category,
      'unit': param.unit,
      'costPrice': param.costPrice,
      'price': param.price,
      'serialNumber': param.serialNumber,
    });
  }
}
