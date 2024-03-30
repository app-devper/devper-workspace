// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'product_mapper.dart';

class OrderMapper {
  String toOrderRequest(CreateOrderParam param) {
    return jsonEncode({
      'customerCode': param.customerCode,
      'customerName': param.customerName,
      'items': param.items
          .map((item) => {
                'stocks': item
                    .getProductStockOrder()
                    .map((stock) => {
                          'stockId': stock.stockId,
                          'quantity': stock.quantity,
                        })
                    .toList(),
                'unitId': item.product.unit.id,
                'productId': item.product.id,
                'quantity': item.quantity,
                'discount': item.discount,
                'price': item.amountPrice(),
                'costPrice': item.amountCostPrice(),
              })
          .toList(),
      'amount': param.amount,
      'type': param.type,
      'total': param.getTotal(),
      'totalCost': param.getTotalCost(),
      'message': param.getMessage(),
      'change': param.amount - param.getTotal(),
    });
  }

  Order toOrderDomain(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      customerCode: json["customerCode"],
      customerName: json["customerName"],
      createdDate: json["createdDate"],
    );
  }

  OrderResult toOrderResultDomain(Map<String, dynamic> json) {
    final mapper = ProductMapper();
    return OrderResult(
      data: toOrderDomain(json["data"]),
      stocks: mapper.toProductStocksDomain(json["stocks"]),
    );
  }

  List<OrderSummary> toOrderSummariesDomain(List json) {
    final items = json.map((data) => toOrderSummaryDomain(data)).toList();
    return items;
  }

  OrderSummary toOrderSummaryDomain(Map<String, dynamic> json) {
    return OrderSummary(
      id: json["id"],
      customerCode: json["customerCode"],
      customerName: json["customerName"],
      createdDate: json["createdDate"],
      total: json["total"].toDouble(),
      totalCost: json["totalCost"]?.toDouble() ?? 0,
      type: json["type"] ?? "Cash",
    );
  }

  OrderDetail toOrderDetailDomain(Map<String, dynamic> json) {
    return OrderDetail(
      id: json["id"],
      createdDate: json["createdDate"],
      totalCost: json["totalCost"]?.toDouble() ?? 0,
      items: toOrderItemDetailsDomain(json["items"]),
      code: json["code"] ?? "",
      customerCode: json["customerCode"],
      customerName: json["customerName"],
    );
  }

  OrderItemDetail toOrderItemDetailDomain(Map<String, dynamic> json) {
    final mapper = ProductMapper();
    Product? product = json["product"] != null ? mapper.toProductDomain(json["product"]) : null;
    Order? order = json["order"] != null ? toOrderDomain(json["order"]) : null;
    return OrderItemDetail(
      id: json["id"],
      product: product,
      quantity: json["quantity"],
      price: json["price"].toDouble(),
      costPrice: json["costPrice"].toDouble(),
      createdDate: json["createdDate"],
      order: order,
    );
  }

  List<OrderItemDetail> toOrderItemDetailsDomain(List json) {
    final items = json.map((data) => toOrderItemDetailDomain(data)).toList();
    return items;
  }
}
