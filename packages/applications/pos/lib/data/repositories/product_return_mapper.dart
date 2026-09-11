// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension ProductReturnJson on Map<String, dynamic> {
  ProductReturn toProductReturnDomain() {
    final json = this;

    return ProductReturn(
      id: json['id'],
      returnNo: json['returnNo'] ?? '',
      orderId: json['orderId'],
      customerCode: json['customerCode'] ?? '',
      reason: json['reason'] ?? '',
      items: ((json['items'] ?? []) as List).toProductReturnItemsDomain(),
      totalRefund: (json['totalRefund'] ?? 0).toDouble(),
      createdDate: json['createdDate'],
    );
  }

  ProductReturnItem toProductReturnItemDomain() {
    final json = this;

    return ProductReturnItem(
      orderItemId: json['orderItemId'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
      refund: (json['refund'] ?? 0).toDouble(),
    );
  }
}

extension ProductReturnListJson on List {
  List<ProductReturnItem> toProductReturnItemsDomain() {
    final json = this;

    return json
        .map((data) =>
            (data as Map<String, dynamic>).toProductReturnItemDomain())
        .toList();
  }

  List<ProductReturn> toProductReturnsDomain() {
    final json = this;

    return json
        .map((data) => (data as Map<String, dynamic>).toProductReturnDomain())
        .toList();
  }
}

extension CreateProductReturnParamRequest on CreateProductReturnParam {
  String toProductReturnRequest() {
    final param = this;

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
}
