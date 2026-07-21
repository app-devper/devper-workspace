// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';

abstract class StockCountRepository {
  Future<StockCount> createStockCount(CreateStockCountParam param);

  Future<List<StockCount>> getStockCounts();

  Future<StockCount> getStockCountById(String stockCountId);
}
