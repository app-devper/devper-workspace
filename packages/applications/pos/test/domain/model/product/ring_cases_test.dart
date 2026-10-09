import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';

/// pos-api decides which price type a Line charges, at what unit price, and
/// which Stock sells first; the till previews it. Both read the same cases:
/// this file is a copy of pos-api's app/domain/sale/testdata/ring_cases.json.
void main() {
  final cases = (jsonDecode(
          File('test/fixtures/ring_cases.json').readAsStringSync())
      as Map<String, dynamic>)['cases'] as List;

  for (final c in cases.cast<Map<String, dynamic>>()) {
    test(c['name'], () {
      final stocks = (c['stocks'] as List)
          .cast<Map<String, dynamic>>()
          .map((s) => ProductStock(
                id: s['id'],
                unitId: 'u',
                productId: 'p',
                receiveCode: '',
                sequence: s['sequence'],
                lotNumber: '',
                costPrice: 0,
                price: (s['price'] as num).toDouble(),
                import: s['quantity'],
                quantity: s['quantity'],
                expireDate: '',
                importDate: '',
              ));
      final prices = (c['prices'] as List)
          .cast<Map<String, dynamic>>()
          .map((p) => ProductPrice(
                id: p['customerType'],
                productId: 'p',
                unitId: 'u',
                customerType: p['customerType'],
                price: (p['price'] as num).toDouble(),
              ));
      final product = ProductUnitItem(
        id: 'p',
        name: 'Product',
        category: '',
        status: productStatusActive,
        createdDate: '',
        unit: ProductUnit(
            id: 'u',
            productId: 'p',
            costPrice: 0,
            unit: 'TAB',
            size: 1,
            barcode: '',
            volume: 0,
            volumeUnit: ''),
        prices: prices.toList(),
        stocks: stocks.toList(),
      );
      final listed = product.stocks.map((s) => s.id).toList();
      final chosen = product
          .getProductStockById(c['stockId'] == '' ? null : c['stockId']);
      final first = chosen ?? product.getFirstSequenceStock();
      final priced = product.priceFrom(c['priceType'], first);
      final want = c['want'] as Map<String, dynamic>;

      expect(priced.type, want['priceType'], reason: 'price type');
      expect(priced.price, (want['unitPrice'] as num).toDouble(),
          reason: 'unit price');
      expect(first?.id ?? '', want['firstStock'], reason: 'first Stock');
      expect(product.stocks.map((s) => s.id), listed,
          reason: "previewing a price must not reorder the Product's Stocks");
    });
  }
}
