class ProductReturnItemParam {
  final String orderItemId;
  final int quantity;
  final double refund;

  ProductReturnItemParam({
    required this.orderItemId,
    required this.quantity,
    required this.refund,
  });
}

class CreateProductReturnParam {
  final String orderId;
  final String reason;
  final List<ProductReturnItemParam> items;

  CreateProductReturnParam({
    required this.orderId,
    required this.reason,
    required this.items,
  });
}
