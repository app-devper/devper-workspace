// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class UpdateCategoryByIdUseCase extends BaseUseCaseParam<CategoryUpdateParam, Category> {
  final CategoryRepository categoryRepo;

  UpdateCategoryByIdUseCase({required this.categoryRepo});

  @override
  Future<Category> call(CategoryUpdateParam param) =>
      categoryRepo.updateCategoryById(param.categoryId, param.param);
}
