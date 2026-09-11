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
    final response =
        await posService.createStockCount(param.toStockCountRequest());
    final result =
        (jsonOrThrow(response) as Map<String, dynamic>).toStockCountDomain();
    productCache.invalidate();
    return result;
  }

  @override
  Future<List<StockCount>> getStockCounts() async {
    final response = await posService.getStockCounts();
    return (jsonOrThrow(response) as List).toStockCountsDomain();
  }

  @override
  Future<StockCount> getStockCountById(String stockCountId) async {
    final response = await posService.getStockCountById(stockCountId);
    return (jsonOrThrow(response) as Map<String, dynamic>).toStockCountDomain();
  }
}
