// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/stock_adjustment_mapper.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';

class StockAdjustmentRepositoryImpl implements StockAdjustmentRepository {
  static const _mapper = StockAdjustmentMapper();

  final PosService posService;

  /// This write moves stock, so the catalogue cache has to be marked stale.
  final CachedList<Product> productCache;

  StockAdjustmentRepositoryImpl({
    required this.posService,
    required this.productCache,
  });

  @override
  Future<StockAdjustment> createStockAdjustment(CreateStockAdjustmentParam param) async {
    final response = await posService.createStockAdjustment(_mapper.toStockAdjustmentRequest(param));
    final result = _mapper.toStockAdjustmentDomain(jsonOrThrow(response));
    productCache.invalidate();
    return result;
  }

  @override
  Future<List<StockAdjustment>> getStockAdjustmentsByProductId(String productId) async {
    final response = await posService.getStockAdjustmentsByProductId(productId);
    return _mapper.toStockAdjustmentsDomain(jsonOrThrow(response));
  }
}
