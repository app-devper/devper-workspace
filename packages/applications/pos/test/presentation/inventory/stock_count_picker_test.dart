import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_item_picker_view_model.dart';

class Products implements ProductRepository {
  bool fail = true;
  @override
  Future<List<Product>> getProducts() async {
    if (fail) throw Exception('offline');
    return [];
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
void main() {
  test('load error is visible and retry clears it', () async {
    final repo = Products();
    final vm = StockCountItemPickerViewModel(productRepo: repo);
    addTearDown(vm.dispose);
    await vm.getProducts();
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.loading, isFalse);
    repo.fail = false;
    await vm.getProducts();
    expect(vm.state.value.error, isNull);
    expect(vm.state.value.loading, isFalse);
  });
}
