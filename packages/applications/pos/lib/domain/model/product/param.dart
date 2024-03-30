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
  final String? lotNumber;
  final String? expireDate;
  final String? receiveId;

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
    required this.lotNumber,
    required this.expireDate,
    required this.receiveId,
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

  CreateProductParam({
    required this.name,
    this.nameEn,
    this.description,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.serialNumber,
    required this.category,
  });
}

class UpdateProductParam {
  final String name;
  final String? nameEn;
  final String? description;
  final String category;

  UpdateProductParam({
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
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
  final int size;
  final String barcode;
  final double volume;
  final String volumeUnit;

  ProductUnitParam({
    required this.productId,
    required this.unit,
    required this.costPrice,
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
