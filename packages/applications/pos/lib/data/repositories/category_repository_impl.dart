// Package imports:
import 'package:common/core/network/error_mapper.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/data/repositories/category_mapper.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  static const _mapper = CategoryMapper();

  final PosService posService;
  final _categories = CachedList<Category>();

  CategoryRepositoryImpl({
    required this.posService,
  });

  @override
  Future<Category> createCategory(CategoryParam param) async {
    final response = await posService.createCategory(_mapper.toCategoryRequest(param));
    final result = _mapper.toCategoryDomain(jsonOrThrow(response));
    _categories.invalidate();
    return result;
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await posService.getCategories();
    final categories = _mapper.toCategoriesDomain(jsonOrThrow(response));
    _categories.fill(categories);
    return categories;
  }

  @override
  Future<Category> getCategoryById(String categoryId) async {
    final response = await posService.getCategoryById(categoryId);
    return _mapper.toCategoryDomain(jsonOrThrow(response));
  }

  @override
  Future<Category> removeCategoryById(String categoryId) async {
    final response = await posService.removeCategoryById(categoryId);
    final result = _mapper.toCategoryDomain(jsonOrThrow(response));
    _categories.invalidate();
    return result;
  }

  @override
  Future<Category> updateCategoryById(String categoryId, CategoryParam param) async {
    final response = await posService.updateCategoryById(categoryId, _mapper.toCategoryRequest(param));
    final result = _mapper.toCategoryDomain(jsonOrThrow(response));
    _categories.invalidate();
    return result;
  }

  @override
  Future<Category> updateDefaultCategoryById(String categoryId) async {
    final response = await posService.updateDefaultCategoryId(categoryId);
    final result = _mapper.toCategoryDomain(jsonOrThrow(response));
    _categories.invalidate();
    return result;
  }

  @override
  Future<bool> requireCustomerOrder(String? value) async {
    final categories = await getLocalCategories();
    final category = categories.where((element) => element.value == value).firstOrNull;
    return category?.requireCustomerOrder ?? false;
  }

  @override
  Future<List<Category>> getLocalCategories() async {
    if (_categories.needsRefresh) {
      return getCategories();
    }
    return Future.value(_categories.items);
  }
}
