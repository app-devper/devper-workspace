import 'package:pos/domain/repositories/product_repository.dart';
// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';

class CreateStockAdjustmentUseCase extends BaseUseCaseParam<CreateStockAdjustmentParam, StockAdjustment> {
  final ProductRepository productRepo;
  final StockAdjustmentRepository stockAdjustmentRepo;

  CreateStockAdjustmentUseCase({required this.stockAdjustmentRepo, required this.productRepo});

  @override
  Future<StockAdjustment> call(CreateStockAdjustmentParam param) async {
    final result = await stockAdjustmentRepo.createStockAdjustment(param);
    productRepo.invalidateProductsCache();
    return result;
  }
}
