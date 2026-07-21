// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class RemoveOrderByIdUseCase extends BaseUseCaseParam<String, OrderDetail> {
  final OrderRepository orderRepo;

  RemoveOrderByIdUseCase({required this.orderRepo});

  @override
  Future<OrderDetail> call(String orderId) => orderRepo.removeOrderById(orderId);
}
