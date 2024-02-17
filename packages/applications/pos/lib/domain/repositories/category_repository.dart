// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';

abstract class CategoryRepository {
  Future<Category> createCategory(CategoryParam param);

  Future<List<Category>> getCategories();

  Future<List<Category>> getLocalCategories();

  Future<Category> getCategoryById(String categoryId);

  Future<Category> updateCategoryById(String categoryId, CategoryParam param);

  Future<Category> updateDefaultCategoryById(String categoryId);

  Future<Category> removeCategoryById(String categoryId);

  Future<bool> requireCustomerOrder(String? value);
}
