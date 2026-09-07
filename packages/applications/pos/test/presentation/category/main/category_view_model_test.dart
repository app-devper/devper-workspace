import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/usecase/category/get_categories_use_case.dart';
import 'package:pos/domain/usecase/category/update_default_category_by_id_use_case.dart';
import 'package:pos/presentation/category/main/category_view_model.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> categories;
  final Object? throws;
  var updateDefaultCalls = 0;

  FakeCategoryRepository({this.categories = const [], this.throws});

  @override
  Future<List<Category>> getCategories() async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return categories;
  }

  @override
  Future<Category> updateDefaultCategoryById(String categoryId) async {
    updateDefaultCalls = updateDefaultCalls + 1;
    final error = throws;
    if (error != null) {
      throw error;
    }
    return categories.first;
  }

  @override
  Future<Category> createCategory(CategoryParam param) => throw UnimplementedError();

  @override
  Future<List<Category>> getLocalCategories() => throw UnimplementedError();

  @override
  Future<Category> getCategoryById(String categoryId) => throw UnimplementedError();

  @override
  Future<Category> updateCategoryById(String categoryId, CategoryParam param) => throw UnimplementedError();

  @override
  Future<Category> removeCategoryById(String categoryId) => throw UnimplementedError();

  @override
  Future<bool> requireCustomerOrder(String? value) => throw UnimplementedError();
}

Category buildCategory(String id) {
  return Category(
    id: id,
    name: 'name-$id',
    value: 'value-$id',
    description: '',
    isDefault: false,
    requireCustomerOrder: false,
  );
}

CategoryViewModel buildViewModel(CategoryRepository repo) {
  return CategoryViewModel(
    getCategoriesUseCase: GetCategoriesUseCase(categoryRepo: repo),
    updateDefaultCategoryByIdUseCase: UpdateDefaultCategoryByIdUseCase(categoryRepo: repo),
  );
}

void main() {
  test('initial state is empty and not loading', () {
    final vm = buildViewModel(FakeCategoryRepository());

    expect(vm.state.value.items, isEmpty);
    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNull);
  });

  test('getCategories populates items and clears loading', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(categories: [buildCategory('1'), buildCategory('2')]),
    );

    await vm.getCategories();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.items, hasLength(2));
    expect(vm.state.value.error, isNull);
  });

  test('getCategories maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getCategories();

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.error, isNotNull);
    expect(vm.state.value.items, isEmpty);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.getCategories();
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });

  test('updateDefaultCategoryById reloads the list on success', () async {
    final repo = FakeCategoryRepository(categories: [buildCategory('1')]);
    final vm = buildViewModel(repo);

    await vm.updateDefaultCategoryById('1');

    expect(repo.updateDefaultCalls, 1);
    expect(vm.state.value.items, hasLength(1));
    expect(vm.state.value.loading, isFalse);
  });

  test('state notifies listeners on change', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(categories: [buildCategory('1')]),
    );
    var notifications = 0;
    vm.state.addListener(() => notifications = notifications + 1);

    await vm.getCategories();

    expect(notifications, greaterThanOrEqualTo(2));
  });
}
