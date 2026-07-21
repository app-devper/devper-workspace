import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/product/product.dart';

ProductUnit _buildUnit() {
  return ProductUnit(
    id: 'unit-1',
    productId: 'product-1',
    costPrice: 5,
    unit: 'เม็ด',
    size: 1,
    barcode: '',
    volume: 0,
    volumeUnit: '',
  );
}

ProductStock _buildStock(String id, int quantity, {int sequence = 1}) {
  return ProductStock(
    id: id,
    unitId: 'unit-1',
    productId: 'product-1',
    receiveCode: '',
    sequence: sequence,
    lotNumber: 'LOT-$id',
    costPrice: 5,
    price: 10,
    import: quantity,
    quantity: quantity,
    expireDate: '',
    importDate: '',
  );
}

ProductUnitItem _buildProductItem(List<ProductStock> stocks) {
  return ProductUnitItem(
    id: 'product-1',
    name: 'Test Product',
    category: 'General',
    status: productStatusActive,
    createdDate: '',
    unit: _buildUnit(),
    prices: const [],
    stocks: stocks,
  );
}

void main() {
  group('OrderItem.getProductStockOrder', () {
    test('allocates entirely from the priced stock when quantity fits', () {
      final stock = _buildStock('stock-1', 10);
      final item = OrderItem(
        product: _buildProductItem([stock]),
        quantity: 4,
        customerType: priceTypeStock,
      );

      final result = item.getProductStockOrder();

      expect(result, hasLength(1));
      expect(result.first.stockId, 'stock-1');
      expect(result.first.quantity, 4);
    });

    test('falls back to the sold-first bucket when oversell is not allowed and stock runs out', () {
      final stock = _buildStock('stock-1', 3);
      final item = OrderItem(
        product: _buildProductItem([stock]),
        quantity: 5,
        customerType: priceTypeStock,
      );

      final result = item.getProductStockOrder();

      expect(result, hasLength(2));
      expect(result[0].stockId, 'stock-1');
      expect(result[0].quantity, 3);
      expect(result[1].stockId, ''); // sold-first bucket, unguarded on the backend
      expect(result[1].quantity, 2);
    });

    test('folds the shortfall onto the last touched lot when oversell is allowed', () {
      final stock = _buildStock('stock-1', 3);
      final item = OrderItem(
        product: _buildProductItem([stock]),
        quantity: 5,
        customerType: priceTypeStock,
      )..allowOversell = true;

      final result = item.getProductStockOrder();

      // The shortfall must be attributed to the real lot (so the backend's
      // oversold/reconciliation path applies), not the unguarded sold-first bucket.
      expect(result, hasLength(1));
      expect(result.first.stockId, 'stock-1');
      expect(result.first.quantity, 5);
    });

    test('walks multiple lots before folding the remaining shortfall onto the last one', () {
      final stockA = _buildStock('stock-a', 2, sequence: 1);
      final stockB = _buildStock('stock-b', 1, sequence: 2);
      final item = OrderItem(
        product: _buildProductItem([stockA, stockB]),
        quantity: 6,
        customerType: priceTypeStock,
      )..allowOversell = true;

      final result = item.getProductStockOrder();

      final total = result.fold<int>(0, (sum, entry) => sum + entry.quantity);
      expect(total, 6, reason: 'every unit requested must still be accounted for');
      expect(result.every((entry) => entry.stockId.isNotEmpty), isTrue,
          reason: 'oversell must never route through the unguarded sold-first bucket once a real lot was touched');
    });

    test('still uses the sold-first bucket when oversell is allowed but no real lot was ever touched', () {
      final item = OrderItem(
        product: _buildProductItem(<ProductStock>[]),
        quantity: 3,
        customerType: 'General',
      )..allowOversell = true;

      final result = item.getProductStockOrder();

      expect(result, hasLength(1));
      expect(result.first.stockId, '');
      expect(result.first.quantity, 3);
    });
  });

  test('toggleAllowOversell flips the flag', () {
    final item = OrderItem(
      product: _buildProductItem([_buildStock('stock-1', 5)]),
      quantity: 1,
      customerType: priceTypeStock,
    );

    expect(item.allowOversell, isFalse);
    item.toggleAllowOversell();
    expect(item.allowOversell, isTrue);
    item.toggleAllowOversell();
    expect(item.allowOversell, isFalse);
  });
}
