class StockCountItemParam {
  final String productId;
  final String stockId;
  final int counted;
  final String productName;
  final String lotNumber;
  final int systemQuantity;

  StockCountItemParam({
    required this.productId,
    required this.stockId,
    required this.counted,
    required this.productName,
    required this.lotNumber,
    required this.systemQuantity,
  });
}

class CreateStockCountParam {
  final String note;
  final List<StockCountItemParam> items;

  CreateStockCountParam({
    required this.note,
    required this.items,
  });
}
