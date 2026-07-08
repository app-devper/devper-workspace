// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class RemoveCategoryByIdUseCase extends BaseUseCaseParam<String, Category> {
  final CategoryRepository categoryRepo;

  RemoveCategoryByIdUseCase({required this.categoryRepo});

  @override
  Future<Category> call(String categoryId) => categoryRepo.removeCategoryById(categoryId);
}
