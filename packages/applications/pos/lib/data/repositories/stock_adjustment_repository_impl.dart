// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/stock_adjustment_mapper.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';

class StockAdjustmentRepositoryImpl implements StockAdjustmentRepository {
  final PosService posService;

  StockAdjustmentRepositoryImpl({
    required this.posService,
  });

  @override
  Future<StockAdjustment> createStockAdjustment(CreateStockAdjustmentParam param) async {
    final mapper = StockAdjustmentMapper();
    final response = await posService.createStockAdjustment(mapper.toStockAdjustmentRequest(param));
    return mapper.toStockAdjustmentDomain(jsonOrThrow(response));
  }

  @override
  Future<List<StockAdjustment>> getStockAdjustmentsByProductId(String productId) async {
    final mapper = StockAdjustmentMapper();
    final response = await posService.getStockAdjustmentsByProductId(productId);
    return mapper.toStockAdjustmentsDomain(jsonOrThrow(response));
  }
}
