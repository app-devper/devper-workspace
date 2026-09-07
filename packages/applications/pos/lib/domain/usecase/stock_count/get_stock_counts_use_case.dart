// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';

class GetStockCountsUseCase extends BaseUseCase<List<StockCount>> {
  final StockCountRepository stockCountRepo;

  GetStockCountsUseCase({required this.stockCountRepo});

  @override
  Future<List<StockCount>> call() => stockCountRepo.getStockCounts();
}
