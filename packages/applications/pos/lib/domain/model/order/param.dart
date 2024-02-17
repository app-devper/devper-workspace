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

  CreateOrderParam({
    required this.customerCode,
    required this.customerName,
    required this.amount,
    required this.items,
    required this.type,
  });

  double getTotal() {
    double total = 0;
    for (var x in items) {
      total += x.amountPrice();
    }
    return total;
  }

  String getMessage() {
    var message = "";
    int no = 1;
    for (var element in items) {
      message += "$no. ${element.getMessage()}\n";
      no += 1;
    }
    return "$message\nรวม ${getTotal()} บาท";
  }
}

class RemoveProductOrderParam {
  final String orderId;
  final String productId;

  RemoveProductOrderParam({
    required this.orderId,
    required this.productId,
  });
}
