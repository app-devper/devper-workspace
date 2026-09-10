import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_lots_use_case.dart';
import 'package:pos/presentation/product/expired/products_expire_ui_model.dart';
import 'package:pos/presentation/product/expired/products_expired_view_model.dart';

ProductLot lot(String id, {double costPrice = 10, int quantity = 2}) {
  return ProductLot(
    id: id,
    productId: 'p1',
    lotNumber: 'L1',
    costPrice: costPrice,
    quantity: quantity,
    expireDate: '2027-01-01T00:00:00Z',
    notify: false,
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.lots = const []});

  final List<ProductLot> lots;
  GetLotsRangeParam? lastParam;

  @override
  Future<List<ProductLot>> getProductLots(GetLotsRangeParam param) async {
    lastParam = param;
    return lots;
  }

  @override
  Future<Product?> getLocalProductById(String productId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProductsExpiredViewModel buildViewModel(FakeProductRepository repo) {
  return ProductsExpiredViewModel(
    getProductLotsUseCase: GetProductLotsUseCase(productRepo: repo),
    getLocalProductByIdUseCase: GetLocalProductByIdUseCase(productRepo: repo),
  );
}

DateTime startOf(GetLotsRangeParam param) =>
    DateTime.parse(param.startDate).toLocal();
DateTime endOf(GetLotsRangeParam param) =>
    DateTime.parse(param.endDate).toLocal();

void main() {
  test('initData offers every range the screen can filter by', () {
    final viewModel = buildViewModel(FakeProductRepository());

    viewModel.initData();

    expect(viewModel.state.value.ranges, hasLength(9));
    expect(viewModel.state.value.ranges.first.value, Range.expired90Day);
    expect(viewModel.state.value.ranges.last.value, Range.before240Days);
  });

  test('an already-expired range ends today and reaches back by its own length',
      () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);

    await viewModel.selectRange(Range.expired30Day);

    expect(endOf(repo.lastParam!), midnight);
    expect(midnight.difference(startOf(repo.lastParam!)).inDays, 30);
  });

  test('an upcoming range starts tomorrow', () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);

    await viewModel.selectRange(Range.before30Days);

    expect(startOf(repo.lastParam!), midnight.add(const Duration(days: 1)));
    expect(endOf(repo.lastParam!), midnight.add(const Duration(days: 31)));
  });

  test('"expires today" asks for today, not an empty window', () async {
    final repo = FakeProductRepository();
    final viewModel = buildViewModel(repo);
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);

    await viewModel.selectRange(Range.today);

    expect(startOf(repo.lastParam!), midnight);
    expect(endOf(repo.lastParam!), midnight.add(const Duration(days: 1)));
  });

  test('total cost multiplies each lot by the quantity still held', () async {
    final repo = FakeProductRepository(lots: [
      lot('a', costPrice: 12.5, quantity: 4),
      lot('b', costPrice: 3, quantity: 10),
    ]);
    final viewModel = buildViewModel(repo);

    await viewModel.selectRange(Range.expired30Day);

    expect(viewModel.state.value.items, hasLength(2));
    expect(viewModel.state.value.totalCost, 12.5 * 4 + 3 * 10);
    expect(viewModel.state.value.loading, isFalse);
  });
}
