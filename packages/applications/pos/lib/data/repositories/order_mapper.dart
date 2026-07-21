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
    final payments = param.payments.isNotEmpty
        ? param.payments
        : [
            OrderPayment(amount: param.amount, type: param.type),
          ];
    return jsonEncode({
      'payments': payments
          .map((payment) => {
                'amount': payment.amount,
                'type': payment.type,
              })
          .toList(),
      'customerCode': param.customerCode,
      'customerName': param.customerName,
      'patientId': param.patientId,
      'pharmacistName': param.pharmacistName,
      'licenseNo': param.licenseNo,
      'prescriberName': param.prescriberName,
      'buyerName': param.buyerName,
      'buyerIdCard': param.buyerIdCard,
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
                'allowOversell': item.allowOversell,
              })
          .toList(),
      'amount': param.amount,
      'type': param.type,
      'total': param.getTotal(),
      'totalCost': param.getTotalCost(),
      'discount': param.getDiscount(),
      'message': param.getMessage(),
      'change': param.amount - param.getTotal(),
    });
  }

  Order toOrderDomain(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      code: json["code"] ?? "",
      customerCode: json["customerCode"],
      customerName: json["customerName"],
      patientId: json["patientId"],
      pharmacistName: json["pharmacistName"],
      licenseNo: json["licenseNo"],
      prescriberName: json["prescriberName"],
      buyerName: json["buyerName"],
      buyerIdCard: json["buyerIdCard"],
      createdDate: json["createdDate"],
      total: (json["total"] ?? 0).toDouble(),
      totalCost: (json["totalCost"] ?? 0).toDouble(),
      discount: (json["discount"] ?? 0).toDouble(),
      type: json["type"] ?? "Cash",
    );
  }

  OrderResult toOrderResultDomain(Map<String, dynamic> json) {
    final mapper = ProductMapper();
    return OrderResult(
      data: toOrderDomain(json["data"]),
      stocks: json["stocks"] != null
          ? mapper.toProductStocksDomain(json["stocks"])
          : [],
    );
  }

  List<OrderSummary> toOrderSummariesDomain(List json) {
    final items = json.map((data) => toOrderSummaryDomain(data)).toList();
    return items;
  }

  OrderSummary toOrderSummaryDomain(Map<String, dynamic> json) {
    return OrderSummary(
      id: json["id"],
      code: json["code"] ?? "",
      customerCode: json["customerCode"],
      customerName: json["customerName"],
      createdDate: json["createdDate"],
      total: json["total"].toDouble(),
      totalCost: json["totalCost"]?.toDouble() ?? 0,
      discount: json["discount"]?.toDouble() ?? 0,
      type: json["type"] ?? "Cash",
    );
  }

  OrderDetail toOrderDetailDomain(Map<String, dynamic> json) {
    return OrderDetail(
      id: json["id"],
      createdDate: json["createdDate"],
      total: json["total"]?.toDouble() ?? 0,
      totalCost: json["totalCost"]?.toDouble() ?? 0,
      discount: json["discount"]?.toDouble() ?? 0,
      type: json["type"] ?? "Cash",
      items: toOrderItemDetailsDomain(json["items"]),
      code: json["code"] ?? "",
      customerCode: json["customerCode"],
      customerName: json["customerName"],
      patientId: json["patientId"],
      pharmacistName: json["pharmacistName"],
      licenseNo: json["licenseNo"],
      prescriberName: json["prescriberName"],
      buyerName: json["buyerName"],
      buyerIdCard: json["buyerIdCard"],
    );
  }

  OrderItemDetail toOrderItemDetailDomain(Map<String, dynamic> json) {
    final mapper = ProductMapper();
    Product? product = json["product"] != null
        ? mapper.toProductDomain(json["product"])
        : null;
    Order? order = json["order"] != null ? toOrderDomain(json["order"]) : null;
    return OrderItemDetail(
      id: json["id"],
      product: product,
      quantity: json["quantity"],
      price: json["price"].toDouble(),
      costPrice: json["costPrice"].toDouble(),
      discount: json["discount"]?.toDouble() ?? 0,
      createdDate: json["createdDate"],
      order: order,
      oversoldQty: json["oversoldQty"] ?? 0,
      returnedQty: json["returnedQty"] ?? 0,
    );
  }

  List<OrderItemDetail> toOrderItemDetailsDomain(List json) {
    final items = json.map((data) => toOrderItemDetailDomain(data)).toList();
    return items;
  }
}
