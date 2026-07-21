class CreateStockAdjustmentParam {
  final String productId;
  final String stockId;
  final String reason;
  final String note;
  final int delta;

  CreateStockAdjustmentParam({
    required this.productId,
    required this.stockId,
    required this.reason,
    required this.note,
    required this.delta,
  });
}
