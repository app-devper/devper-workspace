// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/repositories/category_repository.dart';

class GetLocalCategoriesUseCase extends BaseUseCase<List<Category>> {
  final CategoryRepository categoryRepo;

  GetLocalCategoriesUseCase({required this.categoryRepo});

  @override
  Future<List<Category>> call() => categoryRepo.getLocalCategories();
}
