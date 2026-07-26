import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';
import 'package:pos/domain/usecase/product_return/get_product_returns_by_order_id_use_case.dart';
import 'package:pos/domain/usecase/stock_adjustment/get_stock_adjustments_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/stock_count/get_stock_counts_use_case.dart';
import 'package:pos/presentation/order/return/product_returns_history_view_model.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_history_view_model.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_view_model.dart';

class FakeStockCountRepository implements StockCountRepository {
  final List<StockCount> items;
  final Object? error;

  FakeStockCountRepository({this.items = const [], this.error});

  @override
  Future<List<StockCount>> getStockCounts() async {
    if (error != null) throw error!;
    return items;
  }

  @override
  Future<StockCount> createStockCount(CreateStockCountParam param) {
    throw UnimplementedError();
  }

  @override
  Future<StockCount> getStockCountById(String stockCountId) {
    throw UnimplementedError();
  }
}

class FakeProductReturnRepository implements ProductReturnRepository {
  final List<ProductReturn> items;
  final Object? error;
  String? orderId;

  FakeProductReturnRepository({this.items = const [], this.error});

  @override
  Future<List<ProductReturn>> getProductReturnsByOrderId(
    String orderId,
  ) async {
    if (error != null) throw error!;
    this.orderId = orderId;
    return items;
  }

  @override
  Future<ProductReturn> createProductReturn(CreateProductReturnParam param) {
    throw UnimplementedError();
  }
}

class FakeStockAdjustmentRepository implements StockAdjustmentRepository {
  final List<StockAdjustment> items;
  final Object? error;
  String? productId;

  FakeStockAdjustmentRepository({this.items = const [], this.error});

  @override
  Future<List<StockAdjustment>> getStockAdjustmentsByProductId(
    String productId,
  ) async {
    if (error != null) throw error!;
    this.productId = productId;
    return items;
  }

  @override
  Future<StockAdjustment> createStockAdjustment(
    CreateStockAdjustmentParam param,
  ) {
    throw UnimplementedError();
  }
}

StockCount buildStockCount() {
  return StockCount(
    id: 'sc1',
    countNo: 'COUNT-1',
    note: '',
    items: const [],
    createdDate: '2026-01-01T00:00:00.000Z',
  );
}

ProductReturn buildProductReturn() {
  return ProductReturn(
    id: 'return-1',
    returnNo: 'RT-1',
    orderId: 'order-1',
    customerCode: 'C-1',
    reason: 'damaged',
    items: const [],
    totalRefund: 20,
    createdDate: '2026-01-01T00:00:00.000Z',
  );
}

StockAdjustment buildStockAdjustment() {
  return StockAdjustment(
    id: 'adjustment-1',
    code: 'ADJ-1',
    productId: 'p1',
    stockId: 'stock-1',
    reason: 'นับสต็อก',
    note: '',
    delta: -2,
    before: 10,
    after: 8,
    createdDate: '2026-01-01T00:00:00.000Z',
  );
}

void main() {
  group('StockCountsViewModel', () {
    test('loads stock count history', () async {
      final vm = StockCountsViewModel(
        getStockCountsUseCase: GetStockCountsUseCase(
          stockCountRepo: FakeStockCountRepository(
            items: [buildStockCount()],
          ),
        ),
      );

      await vm.getStockCounts();

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.items.single.id, 'sc1');
      expect(vm.state.value.error, isNull);
    });

    test('maps a typed exception to state.error', () async {
      final vm = StockCountsViewModel(
        getStockCountsUseCase: GetStockCountsUseCase(
          stockCountRepo: FakeStockCountRepository(
            error: const NetworkException(message: 'offline'),
          ),
        ),
      );

      await vm.getStockCounts();

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.items, isEmpty);
      expect(vm.state.value.error, isNotNull);
    });
  });

  group('ProductReturnsHistoryViewModel', () {
    test('loads returns for the requested order', () async {
      final repository = FakeProductReturnRepository(
        items: [buildProductReturn()],
      );
      final vm = ProductReturnsHistoryViewModel(
        getProductReturnsByOrderIdUseCase: GetProductReturnsByOrderIdUseCase(
          productReturnRepo: repository,
        ),
      );

      await vm.getProductReturnsByOrderId('order-1');

      expect(repository.orderId, 'order-1');
      expect(vm.state.value.items.single.id, 'return-1');
      expect(vm.state.value.error, isNull);
    });

    test('maps a typed exception to state.error', () async {
      final vm = ProductReturnsHistoryViewModel(
        getProductReturnsByOrderIdUseCase: GetProductReturnsByOrderIdUseCase(
          productReturnRepo: FakeProductReturnRepository(
            error: const NetworkException(message: 'offline'),
          ),
        ),
      );

      await vm.getProductReturnsByOrderId('order-1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.items, isEmpty);
      expect(vm.state.value.error, isNotNull);
    });
  });

  group('StockAdjustmentHistoryViewModel', () {
    test('loads adjustments for the requested product', () async {
      final repository = FakeStockAdjustmentRepository(
        items: [buildStockAdjustment()],
      );
      final vm = StockAdjustmentHistoryViewModel(
        getStockAdjustmentsByProductIdUseCase:
            GetStockAdjustmentsByProductIdUseCase(
          stockAdjustmentRepo: repository,
        ),
      );

      await vm.getStockAdjustmentsByProductId('p1');

      expect(repository.productId, 'p1');
      expect(vm.state.value.items.single.id, 'adjustment-1');
      expect(vm.state.value.error, isNull);
    });

    test('maps a typed exception to state.error', () async {
      final vm = StockAdjustmentHistoryViewModel(
        getStockAdjustmentsByProductIdUseCase:
            GetStockAdjustmentsByProductIdUseCase(
          stockAdjustmentRepo: FakeStockAdjustmentRepository(
            error: const NetworkException(message: 'offline'),
          ),
        ),
      );

      await vm.getStockAdjustmentsByProductId('p1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.items, isEmpty);
      expect(vm.state.value.error, isNotNull);
    });
  });
}
