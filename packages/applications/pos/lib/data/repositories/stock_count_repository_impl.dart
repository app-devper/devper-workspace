// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/stock_count_mapper.dart';
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';

class StockCountRepositoryImpl implements StockCountRepository {
  final PosService posService;

  /// This write moves stock, so the catalogue cache has to be marked stale.
  final CachedList<Product> productCache;

  StockCountRepositoryImpl({
    required this.posService,
    required this.productCache,
  });

  @override
  Future<StockCount> createStockCount(CreateStockCountParam param) async {
    final mapper = StockCountMapper();
    final response = await posService.createStockCount(mapper.toStockCountRequest(param));
    final result = mapper.toStockCountDomain(jsonOrThrow(response));
    productCache.invalidate();
    return result;
  }

  @override
  Future<List<StockCount>> getStockCounts() async {
    final mapper = StockCountMapper();
    final response = await posService.getStockCounts();
    return mapper.toStockCountsDomain(jsonOrThrow(response));
  }

  @override
  Future<StockCount> getStockCountById(String stockCountId) async {
    final mapper = StockCountMapper();
    final response = await posService.getStockCountById(stockCountId);
    return mapper.toStockCountDomain(jsonOrThrow(response));
  }
}
