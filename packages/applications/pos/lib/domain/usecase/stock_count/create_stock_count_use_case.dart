import 'package:pos/domain/repositories/product_repository.dart';
// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';

class CreateStockCountUseCase extends BaseUseCaseParam<CreateStockCountParam, StockCount> {
  final ProductRepository productRepo;
  final StockCountRepository stockCountRepo;

  CreateStockCountUseCase({required this.stockCountRepo, required this.productRepo});

  @override
  Future<StockCount> call(CreateStockCountParam param) async {
    final result = await stockCountRepo.createStockCount(param);
    productRepo.invalidateProductsCache();
    return result;
  }
}
