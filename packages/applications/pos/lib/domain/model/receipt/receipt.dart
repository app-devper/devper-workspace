// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

class Receipt {
  final ReceiptInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<OrderItemDetail> items;

  const Receipt({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class ReceiptInfo {
  final String number;
  final String date;

  const ReceiptInfo({
    required this.number,
    required this.date,
  });
}
