// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/order/order.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class CreateOrderUseCase extends BaseUseCaseParam<CreateOrderParam, OrderResult> {
  final OrderRepository orderRepo;

  CreateOrderUseCase({required this.orderRepo});

  @override
  Future<OrderResult> call(CreateOrderParam param) => orderRepo.createOrder(param);
}
