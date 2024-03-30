import 'package:pos/domain/model/product/product.dart';

class Order {
  final String id;
  final String customerCode;
  final String customerName;
  final String createdDate;

  Order({
    required this.id,
    required this.customerCode,
    required this.customerName,
    required this.createdDate,
  });
}

class OrderResult {
  final Order data;
  final List<ProductStock> stocks;

  OrderResult({
    required this.data,
    required this.stocks,
  });
}
