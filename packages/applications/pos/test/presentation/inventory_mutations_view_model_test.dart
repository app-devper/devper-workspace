import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';
import 'package:pos/domain/usecase/product_return/create_product_return_use_case.dart';
import 'package:pos/domain/usecase/stock_adjustment/create_stock_adjustment_use_case.dart';
import 'package:pos/presentation/order/return/product_return_view_model.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_view_model.dart';
import 'package:pos/domain/repositories/product_repository.dart';

/// The mutation use cases invalidate the product cache after writing, so they
/// need a repository even though these tests only assert on the write.
class FakeProductRepository implements ProductRepository {
  var invalidated = 0;

  @override
  void invalidateProductsCache() => invalidated++;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeProductReturnRepository implements ProductReturnRepository {
  final ProductReturn result;
  final Object? error;
  CreateProductReturnParam? createParam;

  FakeProductReturnRepository({
    ProductReturn? result,
    this.error,
  }) : result = result ?? buildProductReturn();

  @override
  Future<ProductReturn> createProductReturn(
    CreateProductReturnParam param,
  ) async {
    if (error != null) throw error!;
    createParam = param;
    return result;
  }

  @override
  Future<List<ProductReturn>> getProductReturnsByOrderId(String orderId) async {
    return [result];
  }
}

class FakeStockAdjustmentRepository implements StockAdjustmentRepository {
  final StockAdjustment result;
  final Object? error;
  CreateStockAdjustmentParam? createParam;

  FakeStockAdjustmentRepository({
    StockAdjustment? result,
    this.error,
  }) : result = result ?? buildStockAdjustment();

  @override
  Future<StockAdjustment> createStockAdjustment(
    CreateStockAdjustmentParam param,
  ) async {
    if (error != null) throw error!;
    createParam = param;
    return result;
  }

  @override
  Future<List<StockAdjustment>> getStockAdjustmentsByProductId(
    String productId,
  ) async {
    return [result];
  }
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
    note: 'cycle count',
    delta: -2,
    before: 10,
    after: 8,
    createdDate: '2026-01-01T00:00:00.000Z',
  );
}

void main() {
  group('ProductReturnViewModel', () {
    test('createProductReturn sends payload and exposes result', () async {
      final repository = FakeProductReturnRepository();
      final vm = ProductReturnViewModel(
        createProductReturnUseCase: CreateProductReturnUseCase(
          productReturnRepo: repository,
          productRepo: FakeProductRepository(),
        ),
      );
      final param = CreateProductReturnParam(
        orderId: 'order-1',
        reason: 'damaged',
        items: [
          ProductReturnItemParam(
            orderItemId: 'item-1',
            quantity: 2,
            refund: 20,
          ),
        ],
      );

      await vm.createProductReturn(param);

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.created?.id, 'return-1');
      expect(repository.createParam?.items.single.quantity, 2);

      vm.consumeCreated();
      expect(vm.state.value.created, isNull);
    });

    test('createProductReturn maps a typed exception to state.error', () async {
      final vm = ProductReturnViewModel(
        createProductReturnUseCase: CreateProductReturnUseCase(
          productReturnRepo: FakeProductReturnRepository(
            error: const NetworkException(message: 'offline'),
          ),
          productRepo: FakeProductRepository(),
        ),
      );

      await vm.createProductReturn(
        CreateProductReturnParam(
          orderId: 'order-1',
          reason: 'damaged',
          items: const [],
        ),
      );

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.created, isNull);
      expect(vm.state.value.error, isNotNull);

      vm.consumeError();
      expect(vm.state.value.error, isNull);
    });
  });

  group('StockAdjustmentViewModel', () {
    test('createStockAdjustment sends delta and exposes result', () async {
      final repository = FakeStockAdjustmentRepository();
      final vm = StockAdjustmentViewModel(
        createStockAdjustmentUseCase: CreateStockAdjustmentUseCase(
          stockAdjustmentRepo: repository,
          productRepo: FakeProductRepository(),
        ),
      );
      final param = CreateStockAdjustmentParam(
        productId: 'p1',
        stockId: 'stock-1',
        reason: 'นับสต็อก',
        note: 'cycle count',
        delta: -2,
      );

      await vm.createStockAdjustment(param);

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.created?.after, 8);
      expect(repository.createParam?.delta, -2);

      vm.consumeCreated();
      expect(vm.state.value.created, isNull);
    });

    test(
      'createStockAdjustment maps a typed exception to state.error',
      () async {
        final vm = StockAdjustmentViewModel(
          createStockAdjustmentUseCase: CreateStockAdjustmentUseCase(
            stockAdjustmentRepo: FakeStockAdjustmentRepository(
              error: const NetworkException(message: 'offline'),
            ),
            productRepo: FakeProductRepository(),
          ),
        );

        await vm.createStockAdjustment(
          CreateStockAdjustmentParam(
            productId: 'p1',
            stockId: 'stock-1',
            reason: 'นับสต็อก',
            note: '',
            delta: -2,
          ),
        );

        expect(vm.state.value.loading, isFalse);
        expect(vm.state.value.created, isNull);
        expect(vm.state.value.error, isNotNull);

        vm.consumeError();
        expect(vm.state.value.error, isNull);
      },
    );
  });
}
