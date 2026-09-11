// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';

class ProductReturnMapper {
  const ProductReturnMapper();

  String toProductReturnRequest(CreateProductReturnParam param) {
    return jsonEncode({
      'orderId': param.orderId,
      'reason': param.reason,
      'items': param.items
          .map((item) => {
                'orderItemId': item.orderItemId,
                'quantity': item.quantity,
                'refund': item.refund,
              })
          .toList(),
    });
  }

  ProductReturn toProductReturnDomain(Map<String, dynamic> json) {
    return ProductReturn(
      id: json['id'],
      returnNo: json['returnNo'] ?? '',
      orderId: json['orderId'],
      customerCode: json['customerCode'] ?? '',
      reason: json['reason'] ?? '',
      items: toProductReturnItemsDomain(json['items'] ?? []),
      totalRefund: (json['totalRefund'] ?? 0).toDouble(),
      createdDate: json['createdDate'],
    );
  }

  List<ProductReturnItem> toProductReturnItemsDomain(List json) {
    return json.map((data) => toProductReturnItemDomain(data)).toList();
  }

  ProductReturnItem toProductReturnItemDomain(Map<String, dynamic> json) {
    return ProductReturnItem(
      orderItemId: json['orderItemId'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
      refund: (json['refund'] ?? 0).toDouble(),
    );
  }

  List<ProductReturn> toProductReturnsDomain(List json) {
    return json.map((data) => toProductReturnDomain(data)).toList();
  }
}
