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
      price: json['price'].toDouble(),
      costPrice: json['costPrice'].toDouble(),
      quantity: json['quantity'],
      unit: json['unit'],
      serialNumber: json['serialNumber'],
      createdDate: json['createdDate'],
      category: json['category'],
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
}
