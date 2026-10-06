import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
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
    categoryRepo: repo,
  );
}

void main() {
  test('a save emits the updated record once', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);
    final updated = <Category>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateCategoryById('7', buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(updated.single.id, '7');
    expect(errors, isEmpty);
    expect(vm.state.value.busy, isFalse);
    expect(repo.updatedCategoryId, '7');
  });

  test('a delete emits on its own channel, not the save one', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);
    final updated = <Category>[];
    final removed = <Category>[];
    vm.updated.listen(updated.add);
    vm.removed.listen(removed.add);

    await vm.removeCategoryById('9');
    await Future<void>.delayed(Duration.zero);

    expect(removed.single.id, '9');
    expect(updated, isEmpty,
        reason: 'the two outcomes cannot be mistaken for each other');
    expect(repo.removedCategoryId, '9');
  });

  test('a save then a delete deliver both, in order', () async {
    final vm = buildViewModel(FakeCategoryRepository());
    final seen = <String>[];
    vm.updated.listen((e) => seen.add('updated:${e.id}'));
    vm.removed.listen((e) => seen.add('removed:${e.id}'));

    await vm.updateCategoryById('7', buildParam());
    await vm.removeCategoryById('9');
    await Future<void>.delayed(Duration.zero);

    expect(seen, ['updated:7', 'removed:9'],
        reason: 'the old shape had one slot, so the second replaced the first');
  });

  test('a failure emits an error and no outcome', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final updated = <Category>[];
    final errors = <String>[];
    vm.updated.listen(updated.add);
    vm.errors.listen(errors.add);

    await vm.updateCategoryById('7', buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(updated, isEmpty);
    expect(vm.state.value.busy, isFalse);
  });

  test('a second command while one is in flight is ignored', () async {
    final vm = buildViewModel(FakeCategoryRepository());
    final updated = <Category>[];
    vm.updated.listen(updated.add);

    final first = vm.updateCategoryById('7', buildParam());
    await vm.updateCategoryById('7', buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(updated, hasLength(1));
  });
}
