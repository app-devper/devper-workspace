// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class RemoveOrderItemByIdUseCase extends BaseUseCaseParam<String, OrderItemDetail> {
  final OrderRepository orderRepo;

  RemoveOrderItemByIdUseCase({required this.orderRepo});

  @override
  Future<OrderItemDetail> call(String itemId) => orderRepo.removeOrderItemById(itemId);
}
