// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';

class GetStockAdjustmentsByProductIdUseCase extends BaseUseCaseParam<String, List<StockAdjustment>> {
  final StockAdjustmentRepository stockAdjustmentRepo;

  GetStockAdjustmentsByProductIdUseCase({required this.stockAdjustmentRepo});

  @override
  Future<List<StockAdjustment>> call(String productId) => stockAdjustmentRepo.getStockAdjustmentsByProductId(productId);
}
