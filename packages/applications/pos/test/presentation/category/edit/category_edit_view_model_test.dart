import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/usecase/category/get_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/remove_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/update_category_by_id_use_case.dart';
import 'package:pos/presentation/category/edit/category_edit_state.dart';
import 'package:pos/presentation/category/edit/category_edit_view_model.dart';

class FakeCategoryRepository implements CategoryRepository {
  final Object? throws;
  String? updatedCategoryId;
  String? removedCategoryId;

  FakeCategoryRepository({this.throws});

  @override
  Future<Category> getCategoryById(String categoryId) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    return buildCategory(categoryId);
  }

  @override
  Future<Category> updateCategoryById(
      String categoryId, CategoryParam param) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    updatedCategoryId = categoryId;
    return buildCategory(categoryId);
  }

  @override
  Future<Category> removeCategoryById(String categoryId) async {
    final error = throws;
    if (error != null) {
      throw error;
    }
    removedCategoryId = categoryId;
    return buildCategory(categoryId);
  }

  @override
  Future<Category> createCategory(CategoryParam param) =>
      throw UnimplementedError();

  @override
  Future<List<Category>> getCategories() => throw UnimplementedError();

  @override
  Future<List<Category>> getLocalCategories() => throw UnimplementedError();

  @override
  Future<Category> updateDefaultCategoryById(String categoryId) =>
      throw UnimplementedError();

  @override
  Future<bool> requireCustomerOrder(String? value) =>
      throw UnimplementedError();
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

CategoryParam buildParam() {
  return CategoryParam(
      name: 'ยาสามัญ', value: 'GENERAL', requireCustomerOrder: false);
}

CategoryEditViewModel buildViewModel(CategoryRepository repo) {
  return CategoryEditViewModel(
    getCategoryByIdUseCase: GetCategoryByIdUseCase(categoryRepo: repo),
    updateCategoryByIdUseCase: UpdateCategoryByIdUseCase(categoryRepo: repo),
    removeCategoryByIdUseCase: RemoveCategoryByIdUseCase(categoryRepo: repo),
  );
}

void main() {
  test('initial state is not loading with no result', () {
    final vm = buildViewModel(FakeCategoryRepository());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated, isNull);
    expect(vm.state.value.removed, isNull);
    expect(vm.state.value.error, isNull);
  });

  test('updateCategoryById sets updated on success', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);

    await vm.updateCategoryById('7', buildParam());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated?.id, '7');
    expect(repo.updatedCategoryId, '7');
    expect(vm.state.value.error, isNull);
  });

  test('updateCategoryById maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(
          throws: const NetworkException(message: 'offline')),
    );

    await vm.updateCategoryById('7', buildParam());

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.updated, isNull);
    expect(vm.state.value.error, isNotNull);
  });

  test('removeCategoryById sets removed on success', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);

    await vm.removeCategoryById('9');

    expect(vm.state.value.loading, isFalse);
    expect(vm.state.value.removed?.id, '9');
    expect(repo.removedCategoryId, '9');
  });

  test('getCategoryById maps a typed exception to state.error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(
          throws: const NetworkException(message: 'offline')),
    );

    await vm.getCategoryById('1');

    expect(vm.state.value.error, isNotNull);
  });

  test('consumeUpdated clears the updated result', () async {
    final vm = buildViewModel(FakeCategoryRepository());

    await vm.updateCategoryById('7', buildParam());
    expect(vm.state.value.updated, isNotNull);

    vm.consumeUpdated();

    expect(vm.state.value.updated, isNull);
  });

  test('consumeError clears the error', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(
          throws: const NetworkException(message: 'offline')),
    );

    await vm.updateCategoryById('7', buildParam());
    expect(vm.state.value.error, isNotNull);

    vm.consumeError();

    expect(vm.state.value.error, isNull);
  });

  test('an update result and a delete result cannot both be present', () async {
    final vm = buildViewModel(FakeCategoryRepository());

    await vm.updateCategoryById('7', buildParam());
    expect(vm.state.value.updated, isNotNull);
    expect(vm.state.value.removed, isNull);

    await vm.removeCategoryById('9');

    expect(vm.state.value, isA<CategoryEditRemoved>());
    expect(vm.state.value.removed?.id, '9');
    expect(vm.state.value.updated, isNull,
        reason: 'the stale update result must not survive a delete');
  });

  test('consumeRemoved returns the screen to idle', () async {
    final vm = buildViewModel(FakeCategoryRepository());

    await vm.removeCategoryById('9');
    expect(vm.state.value.removed, isNotNull);

    vm.consumeRemoved();

    expect(vm.state.value, isA<CategoryEditIdle>());
    expect(vm.state.value.removed, isNull);
    expect(vm.state.value.loading, isFalse);
  });
}
