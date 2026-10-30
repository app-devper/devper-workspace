// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/ext/json_ext.dart';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'product_mapper.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension OrderJson on Map<String, dynamic> {
  Order toOrderDomain() {
    final json = this;

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
      total: json.readDouble("total"),
      totalCost: json.readDouble("totalCost"),
      discount: json.readDouble("discount"),
      type: json["type"] ?? "Cash",
    );
  }

  OrderResult toOrderResultDomain() {
    final json = this;
    return OrderResult(
      data: (json["data"] as Map<String, dynamic>).toOrderDomain(),
      stocks: json["stocks"] != null
          ? (json["stocks"] as List).toProductStocksDomain()
          : [],
    );
  }

  OrderSummary toOrderSummaryDomain() {
    final json = this;

    return OrderSummary(
      id: json["id"],
      code: json["code"] ?? "",
      customerCode: json["customerCode"],
      customerName: json["customerName"],
      createdDate: json["createdDate"],
      total: json.readDouble("total"),
      totalCost: json.readDouble("totalCost"),
      discount: json.readDouble("discount"),
      type: json["type"] ?? "Cash",
    );
  }

  OrderDetail toOrderDetailDomain() {
    final json = this;

    return OrderDetail(
      id: json["id"],
      createdDate: json["createdDate"],
      total: json.readDouble("total"),
      totalCost: json.readDouble("totalCost"),
      discount: json.readDouble("discount"),
      type: json["type"] ?? "Cash",
      items: (json["items"] as List).toOrderItemDetailsDomain(),
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

  OrderItemDetail toOrderItemDetailDomain() {
    final json = this;
    Product? product = json["product"] != null
        ? (json["product"] as Map<String, dynamic>).toProductDomain()
        : null;
    Order? order = json["order"] != null
        ? (json["order"] as Map<String, dynamic>).toOrderDomain()
        : null;
    return OrderItemDetail(
      id: json["id"],
      product: product,
      quantity: json["quantity"],
      price: json.readDouble("price"),
      costPrice: json.readDouble("costPrice"),
      discount: json.readDouble("discount"),
      createdDate: json["createdDate"],
      order: order,
      oversoldQty: json["oversoldQty"] ?? 0,
      returnedQty: json["returnedQty"] ?? 0,
    );
  }
}

extension OrderListJson on List {
  List<OrderSummary> toOrderSummariesDomain() {
    final json = this;

    final items = json
        .map((data) => (data as Map<String, dynamic>).toOrderSummaryDomain())
        .toList();
    return items;
  }

  List<OrderItemDetail> toOrderItemDetailsDomain() {
    final json = this;

    final items = json
        .map((data) => (data as Map<String, dynamic>).toOrderItemDetailDomain())
        .toList();
    return items;
  }
}

extension CreateOrderParamRequest on CreateOrderParam {
  String toOrderRequest() {
    final param = this;

    final payments = param.payments.isNotEmpty
        ? param.payments
        : [
            OrderPayment(amount: param.amount, type: param.type),
          ];
    return jsonEncode({
      'saleId': param.saleId,
      'payments': payments
          .map((payment) => {'amount': payment.amount, 'type': payment.type})
          .toList(),
      'type': param.type,
      'customerCode': param.customerCode,
      'customerName': param.customerName,
      'patientId': param.patientId,
      'pharmacistName': param.pharmacistName,
      'licenseNo': param.licenseNo,
      'prescriberName': param.prescriberName,
      'buyerName': param.buyerName,
      'buyerIdCard': param.buyerIdCard,
      'message': param.getMessage(),
      'items': param.items
          .map((item) => {
                'productId': item.product.id,
                'unitId': item.product.unit.id,
                'quantity': item.quantity,
                'priceType': item.customerType,
                'stockId': item.chosenStock?.id ?? '',
                'discount': item.discount,
                'allowOversell': item.allowOversell,
              })
          .toList(),
    });
  }
}
