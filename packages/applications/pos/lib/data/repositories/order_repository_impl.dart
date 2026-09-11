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
  static const _mapper = OrderMapper();

  final PosService posService;

  OrderRepositoryImpl({
    required this.posService,
  });

  @override
  Future<OrderResult> createOrder(CreateOrderParam param) async {
    final response =
        await posService.createOrder(_mapper.toOrderRequest(param));
    return _mapper.toOrderResultDomain(jsonOrThrow(response));
  }

  @override
  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param) async {
    final response =
        await posService.getOrderRange(param.startDate, param.endDate);
    return _mapper.toOrderSummariesDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    final response = await posService.getOrderById(orderId);
    return _mapper.toOrderDetailDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderDetail> removeOrderById(String orderId) async {
    final response = await posService.removeOrderById(orderId);
    return _mapper.toOrderDetailDomain(jsonOrThrow(response));
  }

  @override
  Future<List<OrderItemDetail>> getOrderItemByProductId(
      String productId) async {
    final response = await posService.getOrderItemDetailByProductId(productId);
    return _mapper.toOrderItemDetailsDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderItemDetail> removeProductOrder(
      RemoveProductOrderParam param) async {
    final response = await posService.removeProductByOrderProductId(
        param.orderId, param.productId);
    return _mapper.toOrderItemDetailDomain(jsonOrThrow(response));
  }

  @override
  Future<OrderItemDetail> removeOrderItemById(String itemId) async {
    final response = await posService.removeOrderItemById(itemId);
    return _mapper.toOrderItemDetailDomain(jsonOrThrow(response));
  }
}
