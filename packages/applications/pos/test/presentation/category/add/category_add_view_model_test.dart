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
  Future<Category> getCategoryById(String categoryId) =>
      throw UnimplementedError();

  @override
  Future<Category> updateCategoryById(String categoryId, CategoryParam param) =>
      throw UnimplementedError();

  @override
  Future<Category> updateDefaultCategoryById(String categoryId) =>
      throw UnimplementedError();

  @override
  Future<Category> removeCategoryById(String categoryId) =>
      throw UnimplementedError();

  @override
  Future<bool> requireCustomerOrder(String? value) =>
      throw UnimplementedError();
}

CategoryParam buildParam() {
  return CategoryParam(
      name: 'ยาสามัญ', value: 'GENERAL', requireCustomerOrder: false);
}

CategoryAddViewModel buildViewModel(CategoryRepository repo) {
  return CategoryAddViewModel(
    createCategoryUseCase: CreateCategoryUseCase(categoryRepo: repo),
  );
}

void main() {
  test('initial state is not saving', () {
    final vm = buildViewModel(FakeCategoryRepository());

    expect(vm.state.value.saving, isFalse);
  });

  test('a successful save emits the category once', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);
    final created = <Category>[];
    final errors = <String>[];
    vm.created.listen(created.add);
    vm.errors.listen(errors.add);

    await vm.createCategory(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(created.single.name, 'ยาสามัญ');
    expect(errors, isEmpty);
    expect(repo.createdParam?.value, 'GENERAL');
  });

  test('a failure emits on the error channel and nothing on created', () async {
    final vm = buildViewModel(
      FakeCategoryRepository(
          throws: const NetworkException(message: 'offline')),
    );
    final created = <Category>[];
    final errors = <String>[];
    vm.created.listen(created.add);
    vm.errors.listen(errors.add);

    await vm.createCategory(buildParam());
    await Future<void>.delayed(Duration.zero);

    expect(vm.state.value.saving, isFalse);
    expect(errors, hasLength(1));
    expect(created, isEmpty);
  });

  test('an outcome is delivered once, with nothing to clear', () async {
    final vm = buildViewModel(FakeCategoryRepository());
    final created = <Category>[];
    vm.created.listen(created.add);

    await vm.createCategory(buildParam());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(created, hasLength(1),
        reason: 'the old shape needed consumeCreated to stop it repeating');
  });

  test('a second save while one is in flight is ignored', () async {
    final repo = FakeCategoryRepository();
    final vm = buildViewModel(repo);
    final created = <Category>[];
    vm.created.listen(created.add);

    final first = vm.createCategory(buildParam());
    await vm.createCategory(buildParam());
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(created, hasLength(1));
  });
}
