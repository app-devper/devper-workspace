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

  group('a batch the cashier chose', () {
    test('a copy keeps the choice', () {
      final chosen = _buildStock('chosen', 10, sequence: 2);
      final item = OrderItem(
        product: _buildProductItem([_buildStock('first', 10), chosen]),
        quantity: 1,
        customerType: priceTypeStock,
      )..chooseStock(chosen);

      expect(item.copy().priceType.stock?.id, 'chosen');
      expect(item.copy().chosenStock?.id, 'chosen');
    });
  });
}
