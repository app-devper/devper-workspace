// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';

class GetStockCountByIdUseCase extends BaseUseCaseParam<String, StockCount> {
  final StockCountRepository stockCountRepo;

  GetStockCountByIdUseCase({required this.stockCountRepo});

  @override
  Future<StockCount> call(String stockCountId) => stockCountRepo.getStockCountById(stockCountId);
}
