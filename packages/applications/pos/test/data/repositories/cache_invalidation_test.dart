import 'dart:convert';

import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/category_repository_impl.dart';
import 'package:pos/data/repositories/customer_repository_impl.dart';
import 'package:pos/data/repositories/product_return_repository_impl.dart';
import 'package:pos/data/repositories/stock_adjustment_repository_impl.dart';
import 'package:pos/data/repositories/stock_count_repository_impl.dart';
import 'package:pos/data/repositories/supplier_repository_impl.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/model/stock_adjustment/param.dart';
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/supplier/param.dart';

import 'category_repository_impl_test.dart' show FakeNetworkConfig;

/// Counts the reads so a test can say whether a write actually made the next
/// local read go back to the server.
class _Counter {
  int reads = 0;

  /// The list a GET returns. A write answers with the single entity, the way
  /// the service does.
  final String Function() list;
  final String Function() entity;

  _Counter(this.list, this.entity);

  PosService service() {
    return PosService(
      networkConfig: FakeNetworkConfig(),
      client: CustomClient(inner: MockClient((request) async {
        final isRead = request.method == 'GET';
        if (isRead) reads++;
        return http.Response.bytes(utf8.encode(isRead ? list() : entity()), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      })),
    );
  }
}

String _category(String name) => jsonEncode({
      'id': 'c1',
      'name': name,
      'value': 'v',
      'description': '',
      'default': false,
    });

String _customer(String name) => jsonEncode({
      'id': 'cu1',
      'code': 'C1',
      'name': name,
      'address': '',
      'phone': '',
      'email': '',
      'status': 'ACTIVE',
      'type': '',
    });

String _supplier(String name) => jsonEncode({
      'id': 's1',
      'name': name,
      'address': '',
      'phone': '',
      'taxId': '',
    });

String _categories(String name) => '[${_category(name)}]';
String _customers(String name) => '[${_customer(name)}]';
String _suppliers(String name) => '[${_supplier(name)}]';

/// Just enough for each mapper to build its entity — these tests are about the
/// cache, not the parsing.
final _returnBody = jsonEncode({
  'id': 'r1',
  'returnNo': 'RT-1',
  'orderId': 'o1',
  'customerCode': '',
  'reason': '',
  'totalRefund': 0,
  'createdDate': '',
  'items': [],
});

final _adjustmentBody = jsonEncode({
  'id': 'a1',
  'code': 'AD-1',
  'productId': 'p1',
  'stockId': 's1',
  'before': 1,
  'after': 2,
  'delta': 1,
  'reason': '',
  'note': '',
  'createdDate': '',
});

final _countBody = jsonEncode({
  'id': 'sc1',
  'countNo': 'CT-1',
  'note': '',
  'createdDate': '',
  'items': [],
});

void main() {
  group('a write makes the next local read go back to the server', () {
    test('categories', () async {
      var name = 'before';
      final counter = _Counter(() => _categories(name), () => _category(name));
      final repo = CategoryRepositoryImpl(posService: counter.service());

      expect((await repo.getLocalCategories()).single.name, 'before');
      expect(counter.reads, 1);

      name = 'after';
      await repo.updateCategoryById(
          'c1',
          CategoryParam(
              name: 'after', value: 'v', requireCustomerOrder: false));

      expect((await repo.getLocalCategories()).single.name, 'after',
          reason: 'an edited category used to stay stale until app restart');
      expect(counter.reads, 2);
    });

    test('suppliers', () async {
      var name = 'before';
      final counter = _Counter(() => _suppliers(name), () => _supplier(name));
      final repo = SupplierRepositoryImpl(posService: counter.service());

      expect((await repo.getLocalSuppliers()).single.name, 'before');
      expect(counter.reads, 1);

      name = 'after';
      await repo.createSupplier(
          SupplierParam(name: 'after', address: '', phone: '', taxId: ''));

      expect((await repo.getLocalSuppliers()).single.name, 'after');
      expect(counter.reads, 2);
    });

    test('customers', () async {
      var name = 'before';
      final counter = _Counter(() => _customers(name), () => _customer(name));
      final repo = CustomerRepositoryImpl(posService: counter.service());

      expect((await repo.getLocalCustomers()).single.name, 'before');
      expect(counter.reads, 1);

      name = 'after';
      await repo.updateCustomerById(
          'cu1',
          CustomerParam(
              name: 'after',
              address: '',
              phone: '',
              email: '',
              customerType: ''));

      expect((await repo.getLocalCustomers()).single.name, 'after');
      expect(counter.reads, 2);
    });

    test('a read with nothing written in between is served from memory',
        () async {
      final counter =
          _Counter(() => _categories('one'), () => _category('one'));
      final repo = CategoryRepositoryImpl(posService: counter.service());

      await repo.getLocalCategories();
      await repo.getLocalCategories();
      await repo.getLocalCategories();

      expect(counter.reads, 1,
          reason: 'invalidating on writes must not defeat the cache itself');
    });
  });

  group('writes that move stock mark the catalogue stale', () {
    PosService okService(String body) =>
        _Counter(() => '[]', () => body).service();

    test('a product return', () async {
      final cache = CachedList<Product>();
      cache.fill(const []);
      expect(cache.needsRefresh, isTrue,
          reason: 'an empty list still needs a read');

      cache.fill([_product()]);
      expect(cache.needsRefresh, isFalse);

      await ProductReturnRepositoryImpl(
        posService: okService(_returnBody),
        productCache: cache,
      ).createProductReturn(
          CreateProductReturnParam(orderId: 'o1', reason: '', items: const []));

      expect(cache.needsRefresh, isTrue);
    });

    test('a stock adjustment', () async {
      final cache = CachedList<Product>()..fill([_product()]);

      await StockAdjustmentRepositoryImpl(
        posService: okService(_adjustmentBody),
        productCache: cache,
      ).createStockAdjustment(CreateStockAdjustmentParam(
          productId: 'p1', stockId: 's1', delta: 1, reason: '', note: ''));

      expect(cache.needsRefresh, isTrue);
    });

    test('a stock count', () async {
      final cache = CachedList<Product>()..fill([_product()]);

      await StockCountRepositoryImpl(
        posService: okService(_countBody),
        productCache: cache,
      ).createStockCount(CreateStockCountParam(note: '', items: const []));

      expect(cache.needsRefresh, isTrue);
    });
  });
}

Product _product() => Product(
      id: 'p1',
      name: 'Product',
      status: 'ACTIVE',
      category: '',
      createdDate: '',
      units: const [],
      prices: const [],
      stocks: const [],
    );
