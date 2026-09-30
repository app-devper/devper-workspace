import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';

OrderItemDetail _line(
        {required int quantity, required double price, double discount = 0}) =>
    OrderItemDetail(
      id: 'i1',
      product: null,
      quantity: quantity,
      price: price,
      costPrice: 0,
      discount: discount,
      createdDate: '',
      order: null,
    );

void main() {
  group('what the customer paid for one unit', () {
    test('is the line amount shared out, less the per-unit discount', () {
      expect(_line(quantity: 5, price: 100, discount: 2).paidPerUnit(), 18);
    });

    test('is never negative', () {
      expect(_line(quantity: 2, price: 10, discount: 7).paidPerUnit(), 0);
    });

    test('is nothing for a line of no quantity', () {
      expect(_line(quantity: 0, price: 10).paidPerUnit(), 0);
    });
  });
}
