// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/model/product/request_drug_info.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension ProductJson on Map<String, dynamic> {
  Product toProductDomain() {
    final json = this;

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
          ? (json['drugInfo'] as Map<String, dynamic>).toRequestDrugInfoDomain()
          : null,
      drugRegistrations:
          (json['drugRegistrations'] as List?)?.cast<String>() ?? [],
      units: ((json['units'] ?? []) as List).toProductUnitsDomain(),
      prices: ((json['prices'] ?? []) as List).toProductPricesDomain(),
      stocks: ((json['stocks'] ?? []) as List).toProductStocksDomain(),
    );
  }

  RequestDrugInfo toRequestDrugInfoDomain() {
    final json = this;

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

  ProductUnit toProductUnitDomain() {
    final json = this;

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

  ProductPrice toProductPriceDomain() {
    final json = this;

    return ProductPrice(
      id: json['id'],
      productId: json['productId'],
      unitId: json['unitId'],
      customerType: json['customerType'],
      price: json['price'].toDouble(),
    );
  }

  ProductStock toProductStockDomain() {
    final json = this;

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

  ProductLot toProductLotDomain() {
    final json = this;

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

  String toSerialNumberDomain() {
    final json = this;

    return json['serialNumber'];
  }

  ProductHistory toProductHistoryDomain() {
    final json = this;

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
  CSVImportResult toCSVImportResultDomain() {
    final json = this;

    return CSVImportResult(
      total: json['total'] ?? 0,
      success: json['success'] ?? 0,
      failed: json['failed'] ?? 0,
      errors: (json['errors'] as List?)?.cast<String>() ?? [],
    );
  }
}

extension ProductListJson on List {
  List<Product> toProductsDomain() {
    final json = this;

    final products = json
        .map((data) => (data as Map<String, dynamic>).toProductDomain())
        .toList();
    return products;
  }

  List<ProductUnit> toProductUnitsDomain() {
    final json = this;

    final units = json
        .map((data) => (data as Map<String, dynamic>).toProductUnitDomain())
        .toList();
    return units;
  }

  List<ProductPrice> toProductPricesDomain() {
    final json = this;

    final prices = json
        .map((data) => (data as Map<String, dynamic>).toProductPriceDomain())
        .toList();
    return prices;
  }

  List<ProductStock> toProductStocksDomain() {
    final json = this;

    final stocks = json
        .map((data) => (data as Map<String, dynamic>).toProductStockDomain())
        .toList();
    return stocks;
  }

  List<ProductLot> toProductLotsDomain() {
    final json = this;

    final lots = json
        .map((data) => (data as Map<String, dynamic>).toProductLotDomain())
        .toList();
    return lots;
  }

  List<ProductHistory> toProductHistoriesDomain() {
    final json = this;

    return json
        .map((data) => (data as Map<String, dynamic>).toProductHistoryDomain())
        .toList();
  }

  List<DrugInteractionResult> toDrugInteractionResultsDomain() {
    final json = this;

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
}

extension ProductStringListJson on List<String> {
  String toDrugInteractionCheckRequest() {
    final productIds = this;

    return jsonEncode({'productIds': productIds});
  }
}

extension CreateProductLotParamRequest on CreateProductLotParam {
  String toCreateProductLotRequest() {
    final param = this;

    return jsonEncode({
      'productId': param.productId,
      'quantity': param.quantity,
      'lotNumber': param.lotNumber,
      'expireDate': param.expireDate,
      'costPrice': param.costPrice,
    });
  }
}

extension UpdateProductLotParamRequest on UpdateProductLotParam {
  String toUpdateProductLotRequest() {
    final param = this;

    return jsonEncode({
      'quantity': param.quantity,
      'lotNumber': param.lotNumber,
      'expireDate': param.expireDate,
      'costPrice': param.costPrice,
    });
  }
}

extension ProductParamRequest on ProductParam {
  String toProductRequest() {
    final param = this;

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
      'drugInfo': param.drugInfo?.toRequestDrugInfoRequest(),
      'drugRegistrations': param.drugRegistrations,
    });
  }

  String toUpdateProductRequest() {
    final param = this;

    return jsonEncode({
      'name': param.name,
      'nameEn': param.nameEn,
      'description': param.description,
      'category': param.category,
      'status': param.status,
      'minStock': param.minStock,
      'drugInfo': param.drugInfo?.toRequestDrugInfoRequest(),
      'drugRegistrations': param.drugRegistrations,
    });
  }
}

extension UpdateProductLotQuantityParamRequest
    on UpdateProductLotQuantityParam {
  String toUpdateProductLotQuantityRequest() {
    final param = this;

    return jsonEncode({
      'quantity': param.quantity,
    });
  }
}

extension ProductPriceParamRequest on ProductPriceParam {
  String toProductPriceRequest() {
    final param = this;

    return jsonEncode({
      'productId': param.productId,
      'unitId': param.unitId,
      'customerType': param.customerType,
      'price': param.price,
    });
  }
}

extension ProductUnitParamRequest on ProductUnitParam {
  String toProductUnitRequest() {
    final param = this;

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
}

extension ProductStockParamRequest on ProductStockParam {
  String toProductStockRequest() {
    final param = this;

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
}

extension UpdateProductStockQuantityParamRequest
    on UpdateProductStockQuantityParam {
  String toUpdateProductStockQuantityRequest() {
    final param = this;

    return jsonEncode({
      'quantity': param.quantity,
    });
  }
}

extension UpdateProductStockSequenceParamRequest
    on UpdateProductStockSequenceParam {
  String toUpdateProductStockSequenceRequest() {
    final param = this;

    return jsonEncode({
      'stocks': param.stocks
          .map((stock) => {
                'stockId': stock.stockId,
                'sequence': stock.sequence,
              })
          .toList(),
    });
  }
}

extension CreateProductParamRequest on CreateProductParam {
  String toCreateProductRequest() {
    final param = this;

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
      'drugInfo': param.drugInfo?.toRequestDrugInfoRequest(),
      'drugRegistrations': param.drugRegistrations,
    });
  }

  // Product History mappers
}

extension RequestDrugInfoRequest on RequestDrugInfo {
  Map<String, dynamic> toRequestDrugInfoRequest() {
    final param = this;

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
