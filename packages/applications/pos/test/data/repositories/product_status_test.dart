import 'dart:convert';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/presentation/home/main/product_search_view_model.dart';
import 'category_repository_impl_test.dart' show FakeNetworkConfig;

void main() {
  for (final status in [
    'ACTIVE',
    'Active',
    'INACTIVE',
    'Inactive',
    'ARCHIVED'
  ]) {
    test('sale search handles API product status $status', () async {
      final client = CustomClient(
          inner: MockClient((_) async => http.Response(
              jsonEncode([
                {
                  'id': 'p1',
                  'name': 'Test product',
                  'status': status,
                  'category': '',
                  'createdDate': '',
                  'units': [
                    {
                      'id': 'u1',
                      'productId': 'p1',
                      'unit': 'piece',
                      'costPrice': 20,
                      'size': 1,
                      'barcode': 'test-code',
                      'volume': 0,
                      'volumeUnit': ''
                    }
                  ]
                },
              ]),
              200)));
      final repo = ProductRepositoryImpl(
          posService:
              PosService(networkConfig: FakeNetworkConfig(), client: client));
      await repo.getProducts();
      final vm = ProductSearchViewModel(
          getLocalProductsUseCase: GetLocalProductsUseCase(productRepo: repo));
      addTearDown(vm.dispose);
      await vm.prepareData();
      vm.searchProduct('Test');
      expect(
          vm.items.value, hasLength(status.toUpperCase() == 'ACTIVE' ? 1 : 0));
    });
  }
}
