import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/sale/sale.dart';

// A Sale never reaches the network, so none of this needs a fake.

ProductUnit _unit(String barcode) => ProductUnit(
      id: 'unit-$barcode',
      productId: 'p-$barcode',
      costPrice: 4,
      unit: 'เม็ด',
      size: 1,
      barcode: barcode,
      volume: 0,
      volumeUnit: '',
    );

ProductStock _stock({double price = 10, int quantity = 100}) => ProductStock(
      id: 'stock-1',
      unitId: 'unit-1',
      productId: 'p-1',
      receiveCode: '',
      sequence: 1,
      lotNumber: 'LOT-1',
      costPrice: 4,
      price: price,
      import: quantity,
      quantity: quantity,
      expireDate: '',
      importDate: '',
    );

/// A product priced at 10 off the shelf, 8 for a regular, 6 wholesale.
ProductUnitItem _product(String barcode, {bool withPriceList = true}) {
  return ProductUnitItem(
    id: 'p-$barcode',
    name: 'Paracetamol',
    category: 'General',
    status: productStatusActive,
    createdDate: '',
    unit: _unit(barcode),
    prices: withPriceList
        ? [
            ProductPrice(
                id: '1',
                productId: 'p-$barcode',
                unitId: 'unit-$barcode',
                customerType: customerTypeGeneral,
                price: 10),
            ProductPrice(
                id: '2',
                productId: 'p-$barcode',
                unitId: 'unit-$barcode',
                customerType: customerTypeRegular,
                price: 8),
            ProductPrice(
                id: '3',
                productId: 'p-$barcode',
                unitId: 'unit-$barcode',
                customerType: customerTypeWholesaler,
                price: 6),
          ]
        : const [],
    stocks: [_stock()],
  );
}

Customer _customer(String type) => Customer(
      id: 'c-1',
      code: 'CUST-1',
      name: 'ร้านยาแถวบ้าน',
      address: '',
      phone: '',
      email: '',
      status: 'Active',
      type: type,
    );

void main() {
  group('lines', () {
    test('a scanned product becomes a line of one', () {
      final sale = Sale()..addLine(_product('111'));

      expect(sale.lines, hasLength(1));
      expect(sale.lines.single.quantity, 1);
      expect(sale.isEmpty, isFalse);
    });

    test('the caller cannot edit the lines it is given', () {
      final sale = Sale()..addLine(_product('111'));

      expect(() => sale.lines.clear(), throwsUnsupportedError,
          reason: 'editing a sale is the sale\'s job');
    });

    test('lineFor finds a barcode already on the sale', () {
      final sale = Sale()..addLine(_product('111'));

      expect(sale.lineFor('111'), isNotNull);
      expect(sale.lineFor('222'), isNull);
    });

    test('reducing the last one takes the line off', () {
      final sale = Sale()..addLine(_product('111'));

      sale.decrease(0);

      expect(sale.lines, isEmpty);
    });

    test('a quantity of none takes the line off', () {
      final sale = Sale()..addLine(_product('111'));

      sale.setQuantity(0, 0);

      expect(sale.lines, isEmpty);
    });

    test('an index the sale does not have is ignored, not thrown on', () {
      final sale = Sale()..addLine(_product('111'));

      expect(() => sale.increase(9), returnsNormally);
      expect(() => sale.removeAt(-1), returnsNormally);
      expect(() => sale.toggleOversell(9), returnsNormally);
      expect(sale.lines, hasLength(1));
    });
  });

  group('total', () {
    test('sums quantity by price', () {
      final sale = Sale()..addLine(_product('111'));
      sale.increase(0);

      expect(sale.total, 20);
    });

    test('takes the discount off every one of the line', () {
      final sale = Sale()..addLine(_product('111'));
      sale.setQuantity(0, 3);
      sale.lines.single.updateDiscount(2);

      expect(sale.total, 24, reason: '3 x (10 - 2)');
    });

    test('an empty sale comes to nothing', () {
      expect(Sale().total, 0);
    });
  });

  group('the money offered', () {
    test('covers the sale when it is enough, or more', () {
      final sale = Sale()..addLine(_product('111'));

      expect(sale.covers(10), isTrue);
      expect(sale.covers(20), isTrue, reason: 'the customer takes change');
      expect(sale.covers(9.99), isFalse);
    });

    test('a rounding error is not a reason to refuse payment', () {
      final sale = Sale()..addLine(_product('111'));
      sale.setQuantity(0, 3);
      sale.lines.single.updateDiscountByPercent(33.3);

      expect(sale.covers(sale.total), isTrue);
      expect(sale.covers(sale.total - 0.001), isTrue);
      expect(sale.covers(sale.total - 1), isFalse);
    });
  });

  group('the customer', () {
    test('without one, a line sells at its stock price', () {
      final sale = Sale()..addLine(_product('111'));

      expect(sale.priceList, priceTypeStock);
      expect(sale.lines.single.priceType.price, 10);
    });

    test('picking a wholesale customer reprices what is already scanned', () {
      final sale = Sale()..addLine(_product('111', withPriceList: true));
      expect(sale.total, 10);

      sale.setCustomer(_customer(customerTypeWholesaler));

      expect(sale.lines.single.priceType.price, 6,
          reason: 'this is what the screen could not do before');
      expect(sale.total, 6);
    });

    test('a price the cashier picked by hand survives a change of customer',
        () {
      final sale = Sale()..addLine(_product('111'));
      sale.lines.single.overridePriceType(customerTypeRegular);
      expect(sale.lines.single.priceType.price, 8);

      sale.setCustomer(_customer(customerTypeWholesaler));

      expect(sale.lines.single.priceType.price, 8,
          reason: 'the cashier meant that price');
      expect(sale.total, 8);
    });

    test('a discount is a separate negotiation and is kept', () {
      final sale = Sale()..addLine(_product('111'));
      sale.lines.single.updateDiscount(3);

      sale.setCustomer(_customer(customerTypeWholesaler));

      expect(sale.lines.single.discount, 3);
      expect(sale.total, 3, reason: '6 wholesale less the 3 agreed');
    });

    test('dropping the customer puts the lines back on the shelf price', () {
      final sale = Sale()..addLine(_product('111'));
      sale.setCustomer(_customer(customerTypeWholesaler));

      sale.setCustomer(null);

      expect(sale.lines.single.priceType.price, 10);
    });

    test('a line scanned after the customer is priced for them', () {
      final sale = Sale()..setCustomer(_customer(customerTypeWholesaler));

      sale.addLine(_product('111'));

      expect(sale.lines.single.priceType.price, 6);
    });
  });

  group('the order it produces', () {
    test('records what the customer handed over, not what was owed', () {
      final sale = Sale()..addLine(_product('111'));

      final order = sale.toOrder(tendered: 50, type: 'Cash');

      expect(order.amount, 50, reason: 'the receipt shows the note given');
      expect(order.getTotal(), 10);
      expect(order.payments.single.amount, 50);
      expect(order.payments.single.type, 'Cash');
    });

    test('carries the customer', () {
      final sale = Sale()
        ..addLine(_product('111'))
        ..setCustomer(_customer(customerTypeRegular));

      final order = sale.toOrder(tendered: 8, type: 'Cash');

      expect(order.customerCode, 'CUST-1');
      expect(order.customerName, 'ร้านยาแถวบ้าน');
    });

    test('no customer means no code, not an empty customer', () {
      final order = (Sale()..addLine(_product('111')))
          .toOrder(tendered: 10, type: 'Cash');

      expect(order.customerCode, isEmpty);
      expect(order.customerName, isEmpty);
    });

    test('carries prescription details, and blanks stay absent', () {
      final sale = Sale()..addLine(_product('111'));
      sale.setCompliance(
          patientId: 'P-1', prescriberName: '', pharmacistName: 'ภก. ก');

      final order = sale.toOrder(tendered: 10, type: 'Cash');

      expect(order.patientId, 'P-1');
      expect(order.pharmacistName, 'ภก. ก');
      expect(order.prescriberName, isNull,
          reason: 'an empty box is not a doctor');
    });

    test('the order keeps its own list of lines', () {
      final sale = Sale()..addLine(_product('111'));

      final order = sale.toOrder(tendered: 10, type: 'Cash');
      sale.removeAt(0);

      expect(order.items, hasLength(1),
          reason: 'an order in flight is not edited by the next scan');
    });
  });

  test('clearing takes the customer and the prescription with it', () {
    final sale = Sale()
      ..addLine(_product('111'))
      ..setCustomer(_customer(customerTypeRegular));
    sale.setCompliance(patientId: 'P-1');

    sale.clear();

    expect(sale.isEmpty, isTrue);
    expect(sale.customer, isNull);
    expect(sale.patientId, isNull,
        reason: 'the next customer must not inherit the last one\'s record');
    expect(sale.total, 0);
  });
}
