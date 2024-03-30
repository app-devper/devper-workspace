// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';

abstract class OrderRepository {
  Future<OrderResult> createOrder(CreateOrderParam param);

  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param);

  Future<List<OrderItemDetail>> getOrderItemByProductId(String productId);

  Future<OrderDetail> getOrderById(String orderId);

  Future<bool> updateTotalCostOrderById(String orderId);

  Future<OrderDetail> removeOrderById(String orderId);

  Future<OrderItemDetail> removeProductOrder(RemoveProductOrderParam param);

  Future<OrderItemDetail> removeOrderItemById(String itemId);
}
