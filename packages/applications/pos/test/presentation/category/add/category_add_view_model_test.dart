import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/usecase/category/create_category_use_case.dart';
import 'package:pos/presentation/category/add/category_add_view_model.dart';

class FakeCategoryRepository implements CategoryRepository {
  final Object? throws;
  CategoryParam? createdParam;

  FakeCategoryRepository({this.throws});

  @override
  Future<Category> createCategory(CategoryParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    createdParam = param;
    return Category(
      id: '1',
      name: param.name,
      value: param.value,
      description: param.description ?? '',
      isDefault: false,
      requireCustomerOrder: param.requireCustomerOrder,
    );
  }

  @override
  Future<List<Category>> getCategories() => throw UnimplementedError();

  @override
  Future<List<Category>> getLocalCategories() => throw UnimplementedError();

  @override
  Future<Category> getCategoryById(String categoryId) => throw UnimplementedError();

  @override
  Future<Category> updateCategoryById(String categoryId, CategoryParam param) => throw UnimplementedError();

  @override
  Future<Category> updateDefaultCategoryById(String categoryId) => throw UnimplementedError();

  @override
  Future<Category> removeCategoryById(String categoryId) => throw UnimplementedError();

  @override
  Future<bool> requireCustomerOrder(String? value) => throw UnimplementedError();
}

CategoryParam buildParam() {
  return CategoryParam(name: 'ยาสามัญ', value: 'GENERAL', requireCustomerOrder: false);
}

CategoryAddViewModel buildViewModel(CategoryRepository repo) {
  return CategoryAddViewModel(
    createCategoryUseCase: CreateCategoryUseCase(categoryRepo: repo),
  );
}

void main() {
  test('initial state is not saving with no result', () {
    final vm = buildViewModel(FakeCategoryRepository());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNull);
  });

  test('createCategory sets created on success', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);

    await vm.createCategory(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created?.name, 'ยาสามัญ');
    expect(repo.createdParam?.value, 'GENERAL');
    expect(vm.state.value.error, isNull);
  });

  test('createCategory maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.createCategory(buildParam());

    expect(vm.state.value.saving, isFalse);
    expect(vm.state.value.created, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('consumeCreated clears the created result', () async {
    final vm = buildViewModel(FakeCategoryRepository());

    await vm.createCategory(buildParam());
    expect(vm.state.value.created, isNotNull);

    vm.consumeCreated();

    expect(vm.state.value.created, isNull);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(throws: const NetworkException(message: 'offline')),
    );

    await vm.createCategory(buildParam());
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });
}
