// Project imports:
import 'order_item.dart';

class GetOrderRangeParam {
  final String startDate;
  final String endDate;

  GetOrderRangeParam({
    required this.startDate,
    required this.endDate,
  });
}

class CreateOrderParam {
  final String customerCode;
  final String customerName;
  final List<OrderItem> items;
  final double amount;
  final String type;
  final double discount;
  final List<OrderPayment> payments;
  final String? patientId;
  final String? pharmacistName;
  final String? licenseNo;
  final String? prescriberName;
  final String? buyerName;
  final String? buyerIdCard;
  final String? message;

  CreateOrderParam({
    required this.customerCode,
    required this.customerName,
    required this.amount,
    required this.items,
    required this.type,
    this.discount = 0,
    this.payments = const [],
    this.patientId,
    this.pharmacistName,
    this.licenseNo,
    this.prescriberName,
    this.buyerName,
    this.buyerIdCard,
    this.message,
  });

  double getSubTotal() {
    double total = 0;
    for (var x in items) {
      total += x.amountPrice();
    }
    return total;
  }

  double getTotal() {
    return getSubTotal() - getDiscount();
  }

  double getTotalCost() {
    double total = 0;
    for (var x in items) {
      total += x.amountCostPrice();
    }
    return total;
  }

  double getDiscount() {
    double totalDiscount = discount;
    for (var x in items) {
      totalDiscount += (x.discount * x.quantity);
    }
    return totalDiscount;
  }

  String getMessage() {
    if (message != null && message!.trim().isNotEmpty) {
      return message!;
    }
    var output = "";
    int no = 1;
    for (var element in items) {
      output += "$no. ${element.getMessage()}\n";
      no += 1;
    }
    return "$output\nรวม ${getTotal()} บาท";
  }
}

class OrderPayment {
  final double amount;
  final String type;

  OrderPayment({
    required this.amount,
    required this.type,
  });
}

class RemoveProductOrderParam {
  final String orderId;
  final String productId;

  RemoveProductOrderParam({
    required this.orderId,
    required this.productId,
  });
}
