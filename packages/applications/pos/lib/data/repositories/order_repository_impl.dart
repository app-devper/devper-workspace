// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/order_mapper.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final PosService posService;
  final CachedList<Product> productCache;

  OrderRepositoryImpl({
    required this.posService,
    required this.productCache,
  });

  @override
  Future<OrderResult> createOrder(CreateOrderParam param) {
    // A Sale moves Stock and Sold first, and response.stocks does not carry
    // all of it.
    return productCache.staleAfter(() async {
      final response = await posService.createOrder(param.toOrderRequest());
      return (jsonOrThrow(response) as Map<String, dynamic>)
          .toOrderResultDomain();
    });
  }

  @override
  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param) async {
    final response =
        await posService.getOrderRange(param.startDate, param.endDate);
    return (jsonOrThrow(response) as List).toOrderSummariesDomain();
  }

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    final response = await posService.getOrderById(orderId);
    return (jsonOrThrow(response) as Map<String, dynamic>)
        .toOrderDetailDomain();
  }

  @override
  Future<OrderDetail> removeOrderById(String orderId) {
    return productCache.staleAfter(() async {
      final response = await posService.removeOrderById(orderId);
      return (jsonOrThrow(response) as Map<String, dynamic>)
          .toOrderDetailDomain();
    });
  }

  @override
  Future<List<OrderItemDetail>> getOrderItemByProductId(
      String productId) async {
    final response = await posService.getOrderItemDetailByProductId(productId);
    return (jsonOrThrow(response) as List).toOrderItemDetailsDomain();
  }

  @override
  Future<OrderItemDetail> removeProductOrder(RemoveProductOrderParam param) {
    return productCache.staleAfter(() async {
      final response = await posService.removeProductByOrderProductId(
          param.orderId, param.productId);
      return (jsonOrThrow(response) as Map<String, dynamic>)
          .toOrderItemDetailDomain();
    });
  }

  @override
  Future<OrderItemDetail> removeOrderItemById(String itemId) {
    return productCache.staleAfter(() async {
      final response = await posService.removeOrderItemById(itemId);
      return (jsonOrThrow(response) as Map<String, dynamic>)
          .toOrderItemDetailDomain();
    });
  }
}
