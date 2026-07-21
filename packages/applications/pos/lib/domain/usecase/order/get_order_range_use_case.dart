// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/repositories/order_repository.dart';

class GetOrderRangeUseCase extends BaseUseCaseParam<GetOrderRangeParam, List<OrderSummary>> {
  final OrderRepository orderRepo;

  GetOrderRangeUseCase({required this.orderRepo});

  @override
  Future<List<OrderSummary>> call(GetOrderRangeParam param) => orderRepo.getOrderRange(param);
}
