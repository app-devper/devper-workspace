import 'dart:convert';

import 'package:common/core/error/exception.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/customer_repository_impl.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'package:pos/data/repositories/supplier_repository_impl.dart';
import 'package:pos/domain/model/product/product.dart';

import 'category_repository_impl_test.dart' show FakeNetworkConfig;

/// These reads used to check `response.isSuccessful` by hand and throw
/// toAppException in an else branch. They go through jsonOrThrow now, which
/// does the same thing — these tests say so rather than taking it on trust.
PosService _serviceReturning(int status, String body) {
  return PosService(
    networkConfig: FakeNetworkConfig(),
    client: CustomClient(inner: MockClient((_) async {
      return http.Response.bytes(utf8.encode(body), status,
          headers: {'content-type': 'application/json; charset=utf-8'});
    })),
  );
}

void main() {
  group('a failed list read raises the typed exception', () {
    test('products on 401', () async {
      final repo = ProductRepositoryImpl(
        cache: CachedList<Product>(),
        posService: _serviceReturning(
            401, '{"code":"UM-401","message":"session expired"}'),
      );

      await expectLater(repo.getProducts(), throwsA(isA<AuthException>()));
    });

    test('customers on 403', () async {
      final repo = CustomerRepositoryImpl(
        posService: _serviceReturning(403, '{"message":"forbidden"}'),
      );

      await expectLater(
          repo.getCustomers(), throwsA(isA<ForbiddenException>()));
    });

    test('suppliers on 500', () async {
      final repo = SupplierRepositoryImpl(
        posService: _serviceReturning(500, '{"message":"boom"}'),
      );

      await expectLater(repo.getSuppliers(), throwsA(isA<ServerException>()));
    });

    test('the message from the body survives', () async {
      final repo = SupplierRepositoryImpl(
        posService:
            _serviceReturning(409, '{"code":"POS-409","message":"ชื่อซ้ำ"}'),
      );

      await expectLater(
        repo.getSuppliers(),
        throwsA(isA<ConflictException>()
            .having((e) => e.message, 'message', 'ชื่อซ้ำ')
            .having((e) => e.code, 'code', 'POS-409')),
      );
    });
  });

  test('a failed read leaves the cache untouched', () async {
    final cache = CachedList<Product>();
    final good = ProductRepositoryImpl(
      cache: cache,
      posService: _serviceReturning(
          200,
          jsonEncode([
            {
              'id': 'p1',
              'name': 'Product',
              'status': 'ACTIVE',
              'category': '',
              'createdDate': '',
              'units': [],
            }
          ])),
    );
    await good.getProducts();
    expect(cache.items, hasLength(1));

    final failing = ProductRepositoryImpl(
      cache: cache,
      posService: _serviceReturning(503, '{"message":"offline"}'),
    );
    await expectLater(failing.getProducts(), throwsA(isA<AppException>()));

    expect(cache.items, hasLength(1),
        reason: 'a failed read must not clear what the screen is showing');
  });
}
