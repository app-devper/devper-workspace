import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/sale/money.dart';

OrderItemDetail _line({
  required double price,
  required int quantity,
  double discount = 0,
}) =>
    OrderItemDetail(
      id: 'l1',
      product: null,
      quantity: quantity,
      price: price,
      costPrice: 0,
      discount: discount,
      createdDate: '',
      order: null,
    );

void main() {
  group('a recorded Line is paid what pos-api recorded', () {
    test('a discount with more than two decimals rounds to the satang', () {
      // 10% of 3.33 per unit, three units: pos-api records 30 - 0.999 = 29.
      final line = _line(price: 30, quantity: 3, discount: 0.333);

      expect(line.paid(), 29);
    });

    test('per unit is figured from what was paid', () {
      final line = _line(price: 30, quantity: 3, discount: 0.333);

      expect(line.paidPerUnit(), closeTo(29 / 3, 1e-9));
    });
  });

  test('an Order totals its Lines the way pos-api does', () {
    final lines = [
      _line(price: 4.45, quantity: 1),
      _line(price: 4.45, quantity: 1),
      _line(price: 4.45, quantity: 1),
      _line(price: 30, quantity: 3, discount: 0.333),
    ];

    expect(saleTotal(lines.map((l) => l.paid())), 42.35);
  });
}
