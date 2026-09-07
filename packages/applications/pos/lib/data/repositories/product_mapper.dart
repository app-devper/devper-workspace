// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/model/product/request_drug_info.dart';

class ProductMapper {
  List<Product> toProductsDomain(List json) {
    final products = json.map((data) => toProductDomain(data)).toList();
    return products;
  }

  Product toProductDomain(Map<String, dynamic> json) {
    // API/CSV imports use uppercase; older POS records use title case.
    final rawStatus = (json['status'] as String?)?.trim() ?? '';
    final status = switch (rawStatus.toUpperCase()) {
      '' || 'ACTIVE' => 'Active',
      'INACTIVE' => 'Inactive',
      _ => rawStatus,
    };
    return Product(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 0,
      soldFirst: json['soldFirst'] ?? 0,
      serialNumber: json['serialNumber'] ?? '',
      status: status,
      createdDate: json['createdDate'],
      category: json['category'],
      minStock: json['minStock'] ?? 0,
      drugInfo: json['drugInfo'] != null
          ? toRequestDrugInfoDomain(json['drugInfo'])
          : null,
      drugRegistrations:
          (json['drugRegistrations'] as List?)?.cast<String>() ?? [],
      units: toProductUnitsDomain(json['units'] ?? []),
      prices: toProductPricesDomain(json['prices'] ?? []),
      stocks: toProductStocksDomain(json['stocks'] ?? []),
    );
  }

  RequestDrugInfo toRequestDrugInfoDomain(Map<String, dynamic> json) {
    return RequestDrugInfo(
      genericName: json['genericName'],
      drugType: json['drugType'],
      dosageForm: json['dosageForm'],
      strength: json['strength'],
      indication: json['indication'],
      dosage: json['dosage'],
      sideEffects: json['sideEffects'],
      contraindications: json['contraindications'],
      storageCondition: json['storageCondition'],
      manufacturer: json['manufacturer'],
      registrationNo: json['registrationNo'],
      isControlled: json['isControlled'],
      drugInteractions: (json['drugInteractions'] as List?)?.cast<String>(),
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
      notify: json['notify'] ?? false,
    );
  }

  String toSerialNumberDomain(Map<String, dynamic> json) {
    return json['serialNumber'];
  }

  String toCreateProductLotRequest(CreateProductLotParam param) {
    return jsonEncode({
      'productId': param.productId,
      'quantity': param.quantity,
      'lotNumber': param.lotNumber,
      'expireDate': param.expireDate,
      'costPrice': param.costPrice,
    });
  }

  String toUpdateProductLotRequest(UpdateProductLotParam param) {
    return jsonEncode({
      'quantity': param.quantity,
      'lotNumber': param.lotNumber,
      'expireDate': param.expireDate,
      'costPrice': param.costPrice,
    });
  }

  String toProductRequest(ProductParam param) {
    return jsonEncode({
      'name': param.name,
      'nameEn': param.nameEn,
      'description': param.description,
      'price': param.price,
      'costPrice': param.costPrice ?? 0,
      'quantity': param.quantity,
      'unit': param.unit,
      'serialNumber': param.serialNumber,
      'lotNumber': param.lotNumber,
      'category': param.category,
      'expireDate': param.expireDate,
      'receiveId': param.receiveId,
      'status': param.status,
      'minStock': param.minStock,
      'drugInfo': param.drugInfo == null
          ? null
          : toRequestDrugInfoRequest(param.drugInfo!),
      'drugRegistrations': param.drugRegistrations,
    });
  }

  String toUpdateProductRequest(ProductParam param) {
    return jsonEncode({
      'name': param.name,
      'nameEn': param.nameEn,
      'description': param.description,
      'category': param.category,
      'status': param.status,
      'minStock': param.minStock,
      'drugInfo': param.drugInfo == null
          ? null
          : toRequestDrugInfoRequest(param.drugInfo!),
      'drugRegistrations': param.drugRegistrations,
    });
  }

  String toUpdateProductLotQuantityRequest(
      UpdateProductLotQuantityParam param) {
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
      'price': param.price,
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

  String toUpdateProductStockQuantityRequest(
      UpdateProductStockQuantityParam param) {
    return jsonEncode({
      'quantity': param.quantity,
    });
  }

  String toUpdateProductStockSequenceRequest(
      UpdateProductStockSequenceParam param) {
    return jsonEncode({
      'stocks': param.stocks
          .map((stock) => {
                'stockId': stock.stockId,
                'sequence': stock.sequence,
              })
          .toList(),
    });
  }

  String toCreateProductRequest(CreateProductParam param) {
    return jsonEncode({
      'name': param.name,
      'nameEn': param.nameEn,
      'description': param.description,
      'category': param.category,
      'unit': param.unit,
      'costPrice': param.costPrice,
      'price': param.price,
      'serialNumber': param.serialNumber,
      'status': param.status,
      'minStock': param.minStock,
      'drugInfo': param.drugInfo == null
          ? null
          : toRequestDrugInfoRequest(param.drugInfo!),
      'drugRegistrations': param.drugRegistrations,
    });
  }

  // Product History mappers
  List<ProductHistory> toProductHistoriesDomain(List json) {
    return json.map((data) => toProductHistoryDomain(data)).toList();
  }

  ProductHistory toProductHistoryDomain(Map<String, dynamic> json) {
    return ProductHistory(
      id: json['id'],
      productId: json['productId'],
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      unit: json['unit'] ?? '',
      import: json['import'] ?? 0,
      quantity: json['quantity'] ?? 0,
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      balance: json['balance'] ?? 0,
      createdDate: json['createdDate'] ?? '',
    );
  }

  // Drug Interaction mappers
  String toDrugInteractionCheckRequest(List<String> productIds) {
    return jsonEncode({'productIds': productIds});
  }

  List<DrugInteractionResult> toDrugInteractionResultsDomain(List json) {
    return json
        .map((data) => DrugInteractionResult(
              productAId: data['productAId'] ?? '',
              productAName: data['productAName'] ?? '',
              productBId: data['productBId'] ?? '',
              productBName: data['productBName'] ?? '',
              interaction: data['interaction'] ?? '',
            ))
        .toList();
  }

  // CSV Import mapper
  CSVImportResult toCSVImportResultDomain(Map<String, dynamic> json) {
    return CSVImportResult(
      total: json['total'] ?? 0,
      success: json['success'] ?? 0,
      failed: json['failed'] ?? 0,
      errors: (json['errors'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toRequestDrugInfoRequest(RequestDrugInfo param) {
    return {
      'genericName': param.genericName,
      'drugType': param.drugType,
      'dosageForm': param.dosageForm,
      'strength': param.strength,
      'indication': param.indication,
      'dosage': param.dosage,
      'sideEffects': param.sideEffects,
      'contraindications': param.contraindications,
      'storageCondition': param.storageCondition,
      'manufacturer': param.manufacturer,
      'registrationNo': param.registrationNo,
      'isControlled': param.isControlled,
      'drugInteractions': param.drugInteractions,
    };
  }
}
