import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_item.dart';

class CartStore {
  int cartCount = 8;
  int cartIndex = 0;
  Map<int, List<OrderItem>> cart = {};
  Customer? customer;
}
