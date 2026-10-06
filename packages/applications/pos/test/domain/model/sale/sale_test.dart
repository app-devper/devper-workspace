import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/sale/line_edit.dart';
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

ProductStock _stock({
  String id = 'stock-1',
  int sequence = 1,
  double price = 10,
  int quantity = 100,
}) =>
    ProductStock(
      id: id,
      unitId: 'unit-1',
      productId: 'p-1',
      receiveCode: '',
      sequence: sequence,
      lotNumber: 'LOT-$id',
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

/// The same product, with a second, older batch that sells at 12.
ProductUnitItem _productWithTwoBatches() {
  final product = _product('111', withPriceList: false);
  product.stocks = [
    _stock(id: 'new', sequence: 1, price: 10),
    _stock(id: 'old', sequence: 2, price: 12),
  ];
  return product;
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

    test('scanning a barcode already on the sale adds one more', () {
      final sale = Sale()..addLine(_product('111'));

      expect(sale.increaseBarcode('111'), isTrue);
      expect(sale.lines.single.quantity, 2);
      expect(sale.increaseBarcode('222'), isFalse,
          reason: 'the caller looks up a barcode the sale does not have');
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
      sale.applyEdit(0, const LineEdit(quantity: 3, discount: 2));

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
      // 33.3% of 10, three times over: a total with a long tail.
      sale.applyEdit(0, const LineEdit(quantity: 3, discount: 3.33));
      expect(sale.total, closeTo(20.01, 1e-9),
          reason: 'this used to pass with the discount never applied at all');

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
      sale.applyEdit(
          0,
          const LineEdit(
              quantity: 1,
              discount: 0,
              overridePriceList: customerTypeRegular));
      expect(sale.lines.single.priceType.price, 8);

      sale.setCustomer(_customer(customerTypeWholesaler));

      expect(sale.lines.single.priceType.price, 8,
          reason: 'the cashier meant that price');
      expect(sale.total, 8);
    });

    test('a discount is a separate negotiation and is kept', () {
      final sale = Sale()..addLine(_product('111'));
      sale.applyEdit(0, const LineEdit(quantity: 1, discount: 3));

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
      sale.increase(0);
      sale.removeAt(0);

      expect(order.items, hasLength(1),
          reason: 'an order in flight is not edited by the next scan');
      expect(order.items.single.quantity, 1,
          reason: 'nor are the lines inside it');
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

  group('editing a line', () {
    test('the lines handed out are copies', () {
      final sale = Sale()..addLine(_product('111'));

      final drawn = sale.lines.single;
      drawn.updateDiscount(5);
      drawn.quantity = 9;

      expect(sale.lines.single.discount, 0,
          reason: 'the line dialog used to edit the sale as the cashier typed');
      expect(sale.lines.single.quantity, 1);
      expect(sale.total, 10);
    });

    test('a draft that is never confirmed changes nothing', () {
      final sale = Sale()..addLine(_product('111'));

      final draft = sale.lines.single.copy()
        ..quantity = 4
        ..updateDiscount(2)
        ..overridePriceType(customerTypeWholesaler);
      LineEdit.of(draft); // read, then backed out of

      expect(sale.lines.single.quantity, 1);
      expect(sale.total, 10, reason: 'back means back');
    });

    test('a confirmed draft is applied in one step', () {
      final sale = Sale()..addLine(_product('111'));
      final draft = sale.lines.single.copy()
        ..quantity = 2
        ..updateDiscount(1)
        ..overridePriceType(customerTypeRegular);

      sale.applyEdit(0, LineEdit.of(draft));

      final line = sale.lines.single;
      expect(line.quantity, 2);
      expect(line.discount, 1);
      expect(line.priceType.price, 8);
      expect(line.priceOverridden, isTrue);
      expect(sale.total, 14, reason: '2 x (8 - 1)');
    });

    test('a quantity of none takes the line off', () {
      final sale = Sale()..addLine(_product('111'));

      sale.applyEdit(0, const LineEdit(quantity: 0, discount: 0));

      expect(sale.isEmpty, isTrue,
          reason: 'replacing the line used to keep it at zero');
    });

    test('an edit for a line that has gone is ignored', () {
      final sale = Sale()..addLine(_product('111'));

      expect(() => sale.applyEdit(3, const LineEdit(quantity: 2, discount: 0)),
          returnsNormally);
      expect(sale.lines.single.quantity, 1);
    });

    test('not touching the price does not make it an override', () {
      final sale = Sale()..addLine(_product('111'));

      sale.applyEdit(0, const LineEdit(quantity: 2, discount: 0));
      sale.setCustomer(_customer(customerTypeWholesaler));

      expect(sale.lines.single.priceType.price, 6,
          reason: 'a quantity change is not the cashier choosing a price');
    });
  });

  group('choosing a batch', () {
    test('rings the line up at that batch\'s price', () {
      final product = _productWithTwoBatches();
      final sale = Sale()..addLine(product);
      expect(sale.total, 10, reason: 'the newer batch sells first');

      sale.applyEdit(
          0, LineEdit(quantity: 1, discount: 0, stock: product.stocks[1]));

      expect(sale.lines.single.priceType.stock?.id, 'old');
      expect(sale.total, 12);
    });

    test('leaves the product\'s sell-first order alone', () {
      final product = _productWithTwoBatches();
      final sale = Sale()..addLine(product);

      sale.applyEdit(
          0, LineEdit(quantity: 1, discount: 0, stock: product.stocks[1]));

      expect(product.stocks.map((s) => s.id), ['new', 'old'],
          reason: 'this used to reorder the catalogue, from the till');
      expect(product.stocks.map((s) => s.sequence), [1, 2]);
    });

    test('a chosen batch survives a change of customer', () {
      final product = _productWithTwoBatches();
      final sale = Sale()..addLine(product);
      sale.applyEdit(
          0, LineEdit(quantity: 1, discount: 0, stock: product.stocks[1]));

      sale.setCustomer(null);

      expect(sale.lines.single.priceType.stock?.id, 'old');
    });

    test('the order draws from the chosen batch first', () {
      final product = _productWithTwoBatches();
      final sale = Sale()..addLine(product);
      sale.applyEdit(
          0, LineEdit(quantity: 3, discount: 0, stock: product.stocks[1]));

      final allocation = sale
          .toOrder(tendered: 36, type: 'Cash')
          .items
          .single
          .getProductStockOrder();

      expect(allocation.first.stockId, 'old');
      expect(allocation.first.quantity, 3);
    });
  });
}
