// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/order_mapper.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final PosService posService;

  OrderRepositoryImpl({
    required this.posService,
  });

  @override
  Future<OrderResult> createOrder(CreateOrderParam param) async {
    final mapper = OrderMapper();
    final response = await posService.createOrder(mapper.toOrderRequest(param));
    return mapper.toOrderResultDomain(jsonOrThrow(response));
  }

  @override
  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param) async {
    final mapper = OrderMapper();
    final response =
        await posService.getOrderRange(param.startDate, param.endDate);
    return mapper.toOrderSummariesDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    final mapper = OrderMapper();
    final response = await posService.getOrderById(orderId);
    return mapper.toOrderDetailDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderDetail> removeOrderById(String orderId) async {
    final mapper = OrderMapper();
    final response = await posService.removeOrderById(orderId);
    return mapper.toOrderDetailDomain(jsonOrThrow(response));
  }

  @override
  Future<List<OrderItemDetail>> getOrderItemByProductId(
      String productId) async {
    final mapper = OrderMapper();
    final response = await posService.getOrderItemDetailByProductId(productId);
    return mapper.toOrderItemDetailsDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderItemDetail> removeProductOrder(
      RemoveProductOrderParam param) async {
    final mapper = OrderMapper();
    final response = await posService.removeProductByOrderProductId(
        param.orderId, param.productId);
    return mapper.toOrderItemDetailDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderItemDetail> removeOrderItemById(String itemId) async {
    final mapper = OrderMapper();
    final response = await posService.removeOrderItemById(itemId);
    return mapper.toOrderItemDetailDomain(jsonOrThrow(response));
  }
}
