// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class GetOrderByIdUseCase extends BaseUseCaseParam<String, OrderDetail> {
  final OrderRepository orderRepo;

  GetOrderByIdUseCase({required this.orderRepo});

  @override
  Future<OrderDetail> call(String orderId) => orderRepo.getOrderById(orderId);
}
