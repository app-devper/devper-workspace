// Project imports:
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';

abstract class StockAdjustmentRepository {
  Future<StockAdjustment> createStockAdjustment(CreateStockAdjustmentParam param);

  Future<List<StockAdjustment>> getStockAdjustmentsByProductId(String productId);
}
