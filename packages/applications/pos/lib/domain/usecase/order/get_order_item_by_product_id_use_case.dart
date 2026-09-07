// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class GetOrderItemByProductIdUseCase extends BaseUseCaseParam<String, List<OrderItemDetail>> {
  final OrderRepository orderRepo;

  GetOrderItemByProductIdUseCase({required this.orderRepo});

  @override
  Future<List<OrderItemDetail>> call(String productId) => orderRepo.getOrderItemByProductId(productId);
}
