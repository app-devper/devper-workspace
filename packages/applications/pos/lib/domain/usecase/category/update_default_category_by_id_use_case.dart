// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class UpdateDefaultCategoryByIdUseCase extends BaseUseCaseParam<String, Category> {
  final CategoryRepository categoryRepo;

  UpdateDefaultCategoryByIdUseCase({required this.categoryRepo});

  @override
  Future<Category> call(String categoryId) => categoryRepo.updateDefaultCategoryById(categoryId);
}
