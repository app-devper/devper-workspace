import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/sale/money.dart';

/// pos-api owns Sale money and the till previews it. Both read the same
/// cases: this file is a copy of pos-api's
/// app/domain/sale/testdata/money_cases.json, so a rule changed on one side
/// fails here until the other side matches.
void main() {
  final cases = jsonDecode(
          File('test/fixtures/sale_money_cases.json').readAsStringSync())
      as Map<String, dynamic>;

  double n(Object? v) => (v as num).toDouble();

  group('a Line charges what pos-api records', () {
    for (final c in (cases['lines'] as List).cast<Map<String, dynamic>>()) {
      test(c['name'], () {
        final want = c['want'] as Map<String, dynamic>;
        final got =
            Charge.of(n(c['unitPrice']), c['quantity'] as int, n(c['discount']));

        expect(got.amount, n(want['Amount']), reason: 'amount');
        expect(got.discount, n(want['Discount']), reason: 'discount');
        expect(got.paid, n(want['Paid']), reason: 'paid');
      });
    }
  });

  group('a Sale totals what pos-api records', () {
    for (final c in (cases['sales'] as List).cast<Map<String, dynamic>>()) {
      test(c['name'], () {
        final paid = (c['lines'] as List)
            .cast<Map<String, dynamic>>()
            .map((l) => Charge.of(
                n(l['unitPrice']), l['quantity'] as int, n(l['discount'])).paid);

        expect(saleTotal(paid), n(c['wantTotal']));
      });
    }
  });

  group('a tender settles what pos-api accepts', () {
    for (final c in (cases['tenders'] as List).cast<Map<String, dynamic>>()) {
      test(c['name'], () {
        final got = Tender.of(n(c['tendered']), n(c['total']));

        expect(got.covers, c['wantCovers']);
        expect(got.change, n(c['wantChange']));
      });
    }
  });
}
