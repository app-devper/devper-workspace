import 'dart:convert';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'category_repository_impl_test.dart' show FakeNetworkConfig;

void main() {
  test('invalidated inventory refreshes before local product reads', () async {
    var quantity = 10;
    var calls = 0;
    final cache = CachedList<Product>();
    final repo = ProductRepositoryImpl(
        cache: cache,
        posService: PosService(
      networkConfig: FakeNetworkConfig(),
      client: CustomClient(inner: MockClient((_) async {
        calls++;
        return http.Response(jsonEncode([{
          'id': 'p1', 'name': 'Product', 'quantity': quantity,
          'status': 'ACTIVE', 'category': '', 'createdDate': '', 'units': [],
        }]), 200);
      })),
    ));
    expect((await repo.getLocalProducts()).single.quantity, 10);
    quantity = 11;
    cache.invalidate();
    expect((await repo.getLocalProductById('p1'))!.quantity, 11);
    expect((await repo.getLocalProducts()).single.quantity, 11);
    expect(calls, 2);
  });
}
