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
