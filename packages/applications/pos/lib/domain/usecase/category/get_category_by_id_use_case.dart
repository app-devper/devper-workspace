// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class GetCategoryByIdUseCase extends BaseUseCaseParam<String, Category> {
  final CategoryRepository categoryRepo;

  GetCategoryByIdUseCase({required this.categoryRepo});

  @override
  Future<Category> call(String categoryId) => categoryRepo.getCategoryById(categoryId);
}
