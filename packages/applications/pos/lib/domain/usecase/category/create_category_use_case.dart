// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class CreateCategoryUseCase extends BaseUseCaseParam<CategoryParam, Category> {
  final CategoryRepository categoryRepo;

  CreateCategoryUseCase({required this.categoryRepo});

  @override
  Future<Category> call(CategoryParam param) => categoryRepo.createCategory(param);
}
