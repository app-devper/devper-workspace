import 'request_drug_info.dart';

class ProductParam {
  final String name;
  final String? nameEn;
  final String? description;
  final double price;
  final double? costPrice;
  final String unit;
  final int quantity;
  final String serialNumber;
  final String? category;
  final String status;
  final String? lotNumber;
  final String? expireDate;
  final String? receiveId;
  final int minStock;
  final RequestDrugInfo? drugInfo;
  final List<String> drugRegistrations;

  ProductParam({
    required this.name,
    this.nameEn,
    this.description,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.quantity,
    required this.serialNumber,
    required this.category,
    required this.status,
    required this.lotNumber,
    required this.expireDate,
    required this.receiveId,
    this.minStock = 0,
    this.drugInfo,
    this.drugRegistrations = const [],
  });
}

class CreateProductParam {
  final String name;
  final String? nameEn;
  final String? description;
  final double price;
  final double costPrice;
  final String unit;
  final String serialNumber;
  final String category;
  final String status;
  final int minStock;
  final RequestDrugInfo? drugInfo;
  final List<String> drugRegistrations;

  CreateProductParam({
    required this.name,
    this.nameEn,
    this.description,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.serialNumber,
    required this.category,
    required this.status,
    this.minStock = 0,
    this.drugInfo,
    this.drugRegistrations = const [],
  });
}

class UpdateProductParam {
  final String name;
  final String? nameEn;
  final String? description;
  final String category;
  final String status;
  final int minStock;
  final RequestDrugInfo? drugInfo;
  final List<String> drugRegistrations;

  UpdateProductParam({
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
    required this.status,
    this.minStock = 0,
    this.drugInfo,
    this.drugRegistrations = const [],
  });
}

class CreateProductLotParam {
  final String productId;
  final int quantity;
  final String lotNumber;
  final String expireDate;
  final double costPrice;

  CreateProductLotParam({
    required this.productId,
    required this.quantity,
    required this.lotNumber,
    required this.expireDate,
    required this.costPrice,
  });
}

class UpdateProductLotParam {
  final int quantity;
  final String lotNumber;
  final String expireDate;
  final double costPrice;

  UpdateProductLotParam({
    required this.quantity,
    required this.lotNumber,
    required this.expireDate,
    required this.costPrice,
  });
}

class UpdateProductLotQuantityParam {
  final int quantity;

  UpdateProductLotQuantityParam({
    required this.quantity,
  });
}

class GetLotsRangeParam {
  final String startDate;
  final String endDate;

  GetLotsRangeParam({
    required this.startDate,
    required this.endDate,
  });
}

class ProductPriceParam {
  final String productId;
  final String unitId;
  final String customerType;
  final double price;

  ProductPriceParam({
    required this.productId,
    required this.unitId,
    required this.customerType,
    required this.price,
  });
}

class ProductUnitParam {
  final String productId;
  final String unit;
  final double costPrice;
  final double price;
  final int size;
  final String barcode;
  final double volume;
  final String volumeUnit;

  ProductUnitParam({
    required this.productId,
    required this.unit,
    required this.costPrice,
    this.price = 0,
    required this.size,
    required this.barcode,
    required this.volume,
    required this.volumeUnit,
  });
}

class ProductStockParam {
  final String productId;
  final String unitId;
  final int quantity;
  final double costPrice;
  final double price;
  final String lotNumber;
  final String expireDate;
  final String importDate;

  ProductStockParam({
    required this.productId,
    required this.unitId,
    required this.quantity,
    required this.costPrice,
    required this.price,
    required this.lotNumber,
    required this.expireDate,
    required this.importDate,
  });
}

class UpdateProductStockQuantityParam {
  final int quantity;

  UpdateProductStockQuantityParam({
    required this.quantity,
  });
}

class UpdateProductStockSequenceParam {
  final String productId;
  final List<ProductStockSequenceParam> stocks;

  UpdateProductStockSequenceParam({
    required this.productId,
    required this.stocks,
  });
}

class ProductStockSequenceParam {
  final String stockId;
  final int sequence;

  ProductStockSequenceParam({
    required this.stockId,
    required this.sequence,
  });
}

class ProductUpdateParam {
  final String productId;
  final ProductParam param;

  ProductUpdateParam({
    required this.productId,
    required this.param,
  });
}

class ProductUnitUpdateParam {
  final String id;
  final ProductUnitParam param;

  ProductUnitUpdateParam({
    required this.id,
    required this.param,
  });
}

class ProductPriceUpdateParam {
  final String id;
  final ProductPriceParam param;

  ProductPriceUpdateParam({
    required this.id,
    required this.param,
  });
}

class ProductStockUpdateParam {
  final String id;
  final ProductStockParam param;

  ProductStockUpdateParam({
    required this.id,
    required this.param,
  });
}

class ProductStockQuantityUpdateParam {
  final String id;
  final UpdateProductStockQuantityParam param;

  ProductStockQuantityUpdateParam({
    required this.id,
    required this.param,
  });
}

class ProductLotQuantityUpdateParam {
  final String lotId;
  final UpdateProductLotQuantityParam param;

  ProductLotQuantityUpdateParam({
    required this.lotId,
    required this.param,
  });
}

class ImportProductCSVParam {
  final List<int> bytes;
  final String filename;

  ImportProductCSVParam({
    required this.bytes,
    required this.filename,
  });
}
