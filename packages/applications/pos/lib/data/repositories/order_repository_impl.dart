// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/network/exception.dart';

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
    if (response.isSuccessful) {
      return mapper.toOrderResultDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<OrderSummary>> getOrderRange(GetOrderRangeParam param) async {
    final mapper = OrderMapper();
    final response = await posService.getOrderRange(param.startDate, param.endDate);
    if (response.isSuccessful) {
      return mapper.toOrderSummariesDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<OrderDetail> getOrderById(String orderId) async {
    final mapper = OrderMapper();
    final response = await posService.getOrderById(orderId);
    if (response.isSuccessful) {
      return mapper.toOrderDetailDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<OrderDetail> removeOrderById(String orderId) async {
    final mapper = OrderMapper();
    final response = await posService.removeOrderById(orderId);
    if (response.isSuccessful) {
      return mapper.toOrderDetailDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<List<OrderItemDetail>> getOrderItemByProductId(String productId) async {
    final mapper = OrderMapper();
    final response = await posService.getOrderItemDetailByProductId(productId);
    if (response.isSuccessful) {
      return mapper.toOrderItemDetailsDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<OrderItemDetail> removeProductOrder(RemoveProductOrderParam param) async {
    final mapper = OrderMapper();
    final response = await posService.removeProductByOrderProductId(param.orderId, param.productId);
    if (response.isSuccessful) {
      return mapper.toOrderItemDetailDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

  @override
  Future<bool> updateTotalCostOrderById(String orderId) async {
    final response = await posService.updateTotalCostOrderById(orderId);
    if (response.isSuccessful) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<OrderItemDetail> removeOrderItemById(String itemId) async {
    final mapper = OrderMapper();
    final response = await posService.removeOrderItemById(itemId);
    if (response.isSuccessful) {
      return mapper.toOrderItemDetailDomain(jsonDecode(response.body));
    } else {
      throw HttpException(response);
    }
  }

}
