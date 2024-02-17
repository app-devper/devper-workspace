// Project imports:
import 'package:pos/domain/model/category/category.dart';

abstract class CategoryEditState {}

class InitState extends CategoryEditState {}

class LoadingState extends CategoryEditState {}

class GetCategoryState extends CategoryEditState {
  final Category data;

  GetCategoryState({required this.data});
}

class UpdateCategoryState extends CategoryEditState {
  final Category data;

  UpdateCategoryState({required this.data});
}

class RemoveCategoryState extends CategoryEditState {
  final Category data;

  RemoveCategoryState({required this.data});
}

class ErrorState extends CategoryEditState {
  final String message;

  ErrorState({required this.message});
}
